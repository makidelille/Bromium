import 'package:bromium/core/primitives/ClassContainer.dart';
import 'package:bromium/core/primitives/DivContainer.dart';
import 'package:bromium/core/primitives/OlElementWidget.dart';
import 'package:bromium/core/primitives/UlElementWidget.dart';
import 'package:bromium/core/primitives/WebPageWidget.dart';
import 'package:collection/collection.dart';
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'package:csslib/parser.dart' as csslib;

class Parser {
  static String extractBetweenTags(String tag, String str) {
    final startIndex = str.indexOf("<$tag>");
    final endIndex = str.indexOf("</$tag>", startIndex + tag.length + 2);
    return str.substring(startIndex, endIndex);
  }

  static Widget parseHtml(Uri baseUri, String rawHtml, BuildContext context) {
    final head = extractBetweenTags("head", rawHtml);
    final body = extractBetweenTags("body", rawHtml);

    dom.Document doc = parse(body, encoding: 'utf8');
    dom.Document headDoc = parse(head, encoding: 'utf8');

    return WebPageWidget(
      head: extractHead(baseUri, headDoc.head),
      root: navigateTree(doc.body, null, context),
    );
  }

  static WebPageHead extractHead(Uri baseUri, dom.Element? head) {
    final meta = WebPageHead(baseHref: baseUri);
    if (head == null) return meta;
    for (final child in head.children) {
      switch (child.localName) {
        case "title":
          meta.title = child.text;
          break;
        case "link":
          final href = child.attributes.entries
              .firstWhere((element) => element.key == "href");
          meta.links.add(Uri.parse(href.value));
        case "script":
          final src = child.attributes.entries
              .firstWhere((element) => element.key == "src");
          meta.scripts.add(Uri.parse(src.value));
          break;
        case "meta":
          final name = child.attributes.entries
              .firstWhere((element) => element.key == "name");
          final content = child.attributes.entries
              .firstWhere((element) => element.key == "content");
          meta.metas.add(MapEntry(name.value, content.value));
          break;
        default:
          throw UnimplementedError("Tag ${child.localName} not implemented");
      }
    }

    return meta;
  }

  static Widget navigateTree(
      dom.Node? node, TextStyle? parentStyle, BuildContext context) {
    if (node == null) return Container();

    switch (node.nodeType) {
      case dom.Node.TEXT_NODE:
        return Text(
          node.text ?? "",
          style: parentStyle,
        );
      case dom.Node.ELEMENT_NODE:
        final ele = (node as dom.Element);

        return ClassContainer(
            tag: ele.localName!,
            clazz: ele.className,
            child: extractPrimitive(ele, parentStyle, context));

      default:
        return Container();
    }
  }

  static Widget extractPrimitive(
      dom.Element ele, TextStyle? parentStyle, BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    switch (ele.localName!) {
      case "html":
      case "body":
      case "div":
        return DivContainer(
            children: ele.children
                .map((e) => navigateTree(e, parentStyle, context))
                .toList());
      case "h1":
        return navigateTree(
            ele.firstChild, themeData.textTheme.headlineLarge, context);
      case "h2":
        return navigateTree(
            ele.firstChild, themeData.textTheme.headlineMedium, context);
      case "h3":
        return navigateTree(
            ele.firstChild, themeData.textTheme.headlineSmall, context);
      case "h4":
        return navigateTree(
            ele.firstChild, themeData.textTheme.titleLarge, context);
      case "h5":
        return navigateTree(
            ele.firstChild, themeData.textTheme.titleMedium, context);
      case "h6":
        return navigateTree(
            ele.firstChild, themeData.textTheme.titleSmall, context);
      case "p":
        return navigateTree(
            ele.firstChild, themeData.textTheme.bodyMedium, context);
      case "li":
        return navigateTree(ele.firstChild, parentStyle, context);
      case "a":
        return TextButton(
            onPressed: () => {
                  // TODO: handle navigation
                },
            child: navigateTree(ele.firstChild, parentStyle, context));
      case "ul":
        return UlElementWidget(
            children: ele.children
                .map((e) => navigateTree(e, parentStyle, context))
                .toList());
      case "ol":
        return OlElementWidget(
            children: ele.children
                .map((e) => navigateTree(e, parentStyle, context))
                .toList());
      case "hr":
        return const Divider();
      case "img":
        final src = ele.attributes.entries
            .firstWhere((element) => element.key == "src");
        return Image.network(src.value);
      case "input":
        final placeholder = ele.attributes.entries
            .firstWhereOrNull((element) => element.key == "placeholder");
        final type = ele.attributes.entries
            .firstWhereOrNull((element) => element.key == "type");
        // TODO: handle type
        return TextFormField(
          decoration: InputDecoration(hintText: placeholder?.value),
        );
      case "select":
        return DropdownButton(
          items: [],
          onChanged: null,
        );
      case "textarea":
        return TextFormField();
      case "button":
        return TextButton(
            onPressed: () => {
                  //TODO: implement click
                },
            child: navigateTree(ele.firstChild, parentStyle, context));
      default:
        throw UnimplementedError("Tag ${ele.localName} not implemented");
    }
  }

  static List<css.RuleSet> parseCss(String rawCss) {
    css.StyleSheet sheet = csslib.parse(rawCss);
    return sheet.topLevels.whereType<css.RuleSet>().toList();
  }

  static Widget applyCss(List<css.RuleSet> rules, Widget tree) {
    Widget changed = tree;
    for (final rule in rules) {
      final selector = rule.selectorGroup?.selectors.firstOrNull
          ?.simpleSelectorSequences.firstOrNull?.simpleSelector.name;

      if (selector == null) continue;

      changed = recursiveApplyRule(selector, rule, changed);
    }
    return Container(child: changed);
  }

  static Widget recursiveApplyRule(
      String selector, css.RuleSet rule, Widget tree) {
    switch (tree) {
      case final ClassContainer _:
        if (tree.match(selector)) {
          tree = applyRules(rule, tree);
        }
        if (tree.child != null) {
          tree.child = recursiveApplyRule(selector, rule, tree.child!);
        }

      case final DivContainer _:
        tree.children = tree.children
            .map((child) => recursiveApplyRule(selector, rule, child))
            .toList();
    }
    return tree;
  }

  static ClassContainer applyRules(css.RuleSet rule, ClassContainer widget) {
    for (final declaration
        in rule.declarationGroup.declarations.whereType<css.Declaration>()) {
      if (declaration.expression == null) continue;
      dynamic value = parseExpressionValue(declaration.expression!);
      switch (declaration.property) {
        case "border-color":
          widget.decoration = widget.decoration
              .copyWith(border: Border.all(color: asColor(value)));
          break;
        case "border-width":
          widget.decoration = widget.decoration
              .copyWith(border: Border.all(width: asDouble(value)));
          break;
        case "border-style":
          BorderStyle bStyle = BorderStyle.none;
          switch (value) {
            case "dotted":
            case "double":
            case "groove":
            case "ridge":
            case "dashed":
            case "solid":
              bStyle = BorderStyle.solid;
              break;
            case 'hidden':
            case "none":
            default:
              bStyle = BorderStyle.none;
              break;
          }
          widget.decoration =
              widget.decoration.copyWith(border: Border.all(style: bStyle));
          break;
        case "border-radius":
          widget.decoration = widget.decoration
              .copyWith(borderRadius: BorderRadius.circular(asDouble(value)));
          break;
        case "direction":
          if (widget.child != null && widget.child is DivContainer) {
            DisplayDirection direction = DisplayDirection.column;
            switch (value) {
              case "row":
                direction = DisplayDirection.row;
                break;
              default:
            }
            (widget.child! as DivContainer).displayMode = direction;
          }
          break;
        case "align-items":
          if (widget.child != null && widget.child is DivContainer) {
            MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;

            switch (value) {
              case "fill":
                mainAxisAlignment = MainAxisAlignment.spaceEvenly;
                break;
              case "start":
                mainAxisAlignment = MainAxisAlignment.start;
                break;
              case "center":
                mainAxisAlignment = MainAxisAlignment.center;
                break;
              case "end":
                mainAxisAlignment = MainAxisAlignment.end;
            }
            (widget.child! as DivContainer).mainAxisAlignment =
                mainAxisAlignment;
          }
          break;
        case "color":
          widget.decoration = widget.decoration.copyWith(color: asColor(value));
          break;
        case "padding":
          widget.padding = asDouble(value);
          break;
        case "gap":
          if (widget.child != null && widget.child is DivContainer) {
            (widget.child as DivContainer).gap = asDouble(value);
          }
          break;
        case "font-size":
          if (widget.child != null && widget.child is Text) {
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style:
                  textNode.style!.merge(TextStyle(fontSize: asDouble(value))),
            );
          }
          break;
        case "font-height":
          //TODO: handle font-height
          break;
        case "font-family":
          if (widget.child != null && widget.child is Text) {
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style: textNode.style!.merge(TextStyle(fontFamily: value)),
            );
          }
          break;
        case "font-weight ":
          if (widget.child != null && widget.child is Text) {
            FontWeight weight = FontWeight.normal;
            switch (value) {
              case 'ultralight':
                weight = FontWeight.w100;
                break;
              case "light":
                weight = FontWeight.w200;
                break;
              case "normal":
                weight = FontWeight.normal;
                break;
              case "bold":
                weight = FontWeight.bold;
                break;
              case "ultrabold":
                weight = FontWeight.w800;
                break;
              case "heavy":
                weight = FontWeight.w900;
                break;
            }

            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style: textNode.style!.merge(TextStyle(fontWeight: weight)),
            );
          }
          break;
        case "underline":
          if (widget.child != null && widget.child is Text) {
            TextDecoration textDecoration = TextDecoration.none;
            switch (value) {
              case 'none':
                textDecoration = TextDecoration.none;
                break;
              case "single":
                textDecoration = TextDecoration.underline;
                break;
              case "double":
              case "low":
              case "error":
                textDecoration = TextDecoration.underline;
                break;
            }
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style:
                  textNode.style!.merge(TextStyle(decoration: textDecoration)),
            );
          }
          break;
        case "overline-color":
        case "underline-color":
        case "strikethrough-color":
          if (widget.child != null && widget.child is Text) {
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style: textNode.style!
                  .merge(TextStyle(decorationColor: asColor(value))),
            );
          }
          break;
        case "overline":
          if (widget.child != null && widget.child is Text) {
            TextDecoration textDecoration = TextDecoration.none;
            switch (value) {
              case 'none':
                textDecoration = TextDecoration.none;
                break;
              case "overline":
                textDecoration = TextDecoration.overline;
                break;
            }
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style:
                  textNode.style!.merge(TextStyle(decoration: textDecoration)),
            );
          }

          break;
        case "strikethrough":
          if (widget.child != null && widget.child is Text) {
            TextDecoration textDecoration = TextDecoration.none;
            switch (value) {
              case 'false':
                textDecoration = TextDecoration.none;
                break;
              case "true":
                textDecoration = TextDecoration.lineThrough;
                break;
            }
            final textNode = (widget.child as Text);
            widget.child = Text(
              textNode.data!,
              style:
                  textNode.style!.merge(TextStyle(decoration: textDecoration)),
            );
          }
          break;
        case "margin-left":
          widget.margin += EdgeInsets.only(left: asDouble(value));
          break;
        case "margin-right":
          widget.margin += EdgeInsets.only(right: asDouble(value));
          break;
        case "margin-top":
          widget.margin += EdgeInsets.only(top: asDouble(value));
          break;
        case "margin-bottom":
          widget.margin += EdgeInsets.only(bottom: asDouble(value));
          break;
        case "width":
          widget.width = asDouble(value);
          break;
        case "height":
          widget.height = asDouble(value);
          break;
      }
    }
    return widget;
  }

  static double asDouble(dynamic value) {
    if (value is double) return value;
    final dble = double.tryParse(value);
    if (dble != null) return dble;
    print("Could not parse to doule $value");
    return 0;
  }

  static Color asColor(dynamic value) {
    if (value is int) return Color(value);
    final i = int.tryParse(value);
    if (i != null) return Color(i);
    print("Could not parse to doule $value");
    return Colors.red;
  }

  static dynamic parseExpressionValue(css.Expression expression) {
    if (expression is css.Expressions) {
      return expression.expressions.map((e) => parseExpressionValue(e)).first;
    }

    switch (expression) {
      case css.FunctionTerm _:
        switch (expression.value) {
          case 'rgb':
            return 0;
        }
        break;
      case css.HexColorTerm _:
        return expression.value as int;
      case css.LengthTerm _:
        return (expression.value as int).toDouble();
      case css.LiteralTerm _:
        return expression.text;
      default:
        return null;
    }
  }
}
