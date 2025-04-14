import 'package:flutter/material.dart';

import '../screens/settings_screen.dart';

class ChartBar extends StatelessWidget {
  final double fraction;

  const ChartBar(this.fraction, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * .04,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: SettingsScreen.selectedColorPair['absent']!,
                  ),
                  color: SettingsScreen.selectedColorPair['absent'],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SettingsScreen.selectedColorPair['present'],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
