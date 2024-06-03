import 'package:flutter/material.dart';

enum DisplayDirection { column, row }

class DivContainer extends StatelessWidget {
  final List<Widget> children;
  final DisplayDirection displayMode;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const DivContainer(
      {super.key,
      required this.children,
      this.displayMode = DisplayDirection.column,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return displayMode == DisplayDirection.column
        ? Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          )
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
  }
}
