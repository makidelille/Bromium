import 'package:flutter/material.dart';

class ClassContainer extends StatelessWidget {
  final String? clazz;
  final Widget? child;

  const ClassContainer({super.key, this.clazz, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(child: child);
  }
}
