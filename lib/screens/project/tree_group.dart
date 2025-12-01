import 'package:flutter/material.dart';

class TreeGroup extends StatelessWidget {
  final List<Widget> children;

  const TreeGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 3))),
      child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(children: children)),
    );
  }
}
