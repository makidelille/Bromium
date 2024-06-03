import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class OlElementWidget extends StatelessWidget {
  final List<Widget> children;

  const OlElementWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.mapIndexed((index, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(child: child),
            ],
          );
        }).toList(),
      ),
    );
  }
}
