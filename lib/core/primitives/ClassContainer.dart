import 'package:flutter/material.dart';

class ClassContainer extends StatefulWidget {
  final String tag;
  final String? clazz;

  Widget? child;

  double? width;
  double? height;

  BoxDecoration decoration = const BoxDecoration();

  double padding = 0.0;

  EdgeInsets margin = const EdgeInsets.all(0);

  ClassContainer({
    super.key,
    required this.tag,
    this.clazz,
    this.child,
  });

  bool match(String selector) {
    return tag == selector || clazz == selector;
  }

  @override
  State<ClassContainer> createState() => _ClassContainerState();
}

class _ClassContainerState extends State<ClassContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: Container(
        decoration: widget.decoration,
        child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.all(widget.padding),
              child: widget.child,
            )),
      ),
    );
  }
}
