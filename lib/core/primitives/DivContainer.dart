import 'package:flutter/material.dart';

enum DisplayDirection { column, row }

class DivContainer extends StatefulWidget {
  List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  DisplayDirection displayMode;
  MainAxisAlignment mainAxisAlignment;

  double gap = 0.0;

  DivContainer(
      {super.key,
      required this.children,
      this.displayMode = DisplayDirection.column,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  State<DivContainer> createState() => _DivContainerState();
}

class _DivContainerState extends State<DivContainer> {
  @override
  Widget build(BuildContext context) {
    List<Widget> childrenWithGaps = widget.children;
    int targetLength = (widget.children.length - 1) * 2;
    for (int i = 1; i < targetLength; i += 2) {
      childrenWithGaps.insert(
          i, SizedBox(width: widget.gap, height: widget.gap));
    }
    return widget.displayMode == DisplayDirection.column
        ? Column(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: widget.children,
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: widget.children,
            ),
          );
  }
}
