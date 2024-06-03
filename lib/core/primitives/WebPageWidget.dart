import 'package:bromium/core/network.dart';
import 'package:bromium/core/parser.dart';
import 'package:collection/collection.dart';
import 'package:csslib/visitor.dart';
import 'package:flutter/material.dart';

class WebPageHead {
  Uri baseHref;
  String? title;
  List<Uri> links = [];
  List<MapEntry<String, String>> metas = [];
  List<Uri> scripts = [];

  WebPageHead({required this.baseHref});

  List<Uri> get styles {
    return links
        .where((element) => element.path.endsWith(".css"))
        .map((e) => baseHref.replace(path: e.path))
        .toList();
  }

  Uri? get favIcon {
    final path =
        links.firstWhereOrNull((element) => element.path.endsWith(".png"));
    if (path == null) return null;
    return baseHref.replace(path: path.path);
  }
}

class WebPageWidget extends StatefulWidget {
  final WebPageHead head;
  final Widget root;

  const WebPageWidget({super.key, required this.root, required this.head});

  @override
  State<WebPageWidget> createState() => _WebPageWidgetState();
}

class _WebPageWidgetState extends State<WebPageWidget> {
  Future<List<RuleSet>> fetchCss() async {
    List<RuleSet> rules = [];
    for (final cssSrc in widget.head.styles) {
      final cssRaw = await Network.fetch(cssSrc);
      rules.addAll(Parser.parseCss(cssRaw));
    }

    return rules;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchCss(),
        builder: (context, snap) => !snap.hasData
            ? widget.root
            : Parser.applyCss(snap.data!, widget.root));
  }
}
