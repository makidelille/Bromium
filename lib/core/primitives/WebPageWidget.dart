import 'package:flutter/material.dart';

class WebPageHead {
  String? title;
  List<String> links = [];
  List<MapEntry<String, String>> metas = [];
  List<String> scripts = [];
}

class WebPageWidget extends StatelessWidget {
  final WebPageHead head;
  final Widget root;

  const WebPageWidget({super.key, required this.root, required this.head});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return root;
  }
}
