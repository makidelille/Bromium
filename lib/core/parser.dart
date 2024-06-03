import 'dart:ffi';

import 'package:bromium/core/primitives/ClassContainer.dart';
import 'package:bromium/core/primitives/DivContainer.dart';
import 'package:bromium/core/primitives/OlElementWidget.dart';
import 'package:bromium/core/primitives/UlElementWidget.dart';
import 'package:bromium/core/primitives/WebPageWidget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class Parser {
  static String extractBetweenTags(String tag, String str) {
    final startIndex = str.indexOf("<$tag>");
    final endIndex = str.indexOf("</$tag>", startIndex + tag.length + 2);
    return str.substring(startIndex, endIndex);
  }

  static Widget parseHtml(String rawHtml, BuildContext context) {
    final head = extractBetweenTags("head", rawHtml);
    final body = extractBetweenTags("body", rawHtml);

    dom.Document doc = parse(body, encoding: 'utf8');
    dom.Document headDoc = parse(head, encoding: 'utf8');

    return WebPageWidget(
      head: extractHead(headDoc.head),
      root: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: navigateTree(doc.body, null, context)),
    );
  }

  static WebPageHead extractHead(dom.Element? head) {
    if (head == null) return WebPageHead();
    final meta = WebPageHead();
    for (final child in head.children) {
      switch (child.localName) {
        case "title":
          meta.title = child.text;
          break;
        case "link":
          final href = child.attributes.entries
              .firstWhere((element) => element.key == "href");
          meta.links.add(href.value);
        case "script":
          final src = child.attributes.entries
              .firstWhere((element) => element.key == "src");
          meta.scripts.add(src.value);
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

  static void parseCss(String rawCss) {}

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
}
