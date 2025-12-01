import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArrowShootingGame extends StatefulWidget {
  const ArrowShootingGame({super.key});

  @override
  State<ArrowShootingGame> createState() => _ArrowShootingGameState();
}

class _ArrowShootingGameState extends State<ArrowShootingGame>
    with TickerProviderStateMixin {
  double targetX = 0;
  bool movingRight = true;
  Timer? targetTimer;

  double arrowY = 1;
  bool isArrowFlying = false;

  int arrowsLeft = 10;
  int score = 0;

  final double arrowWidth = 10;
  final double arrowHeight = 40;
  final double targetSize = 80;
  final double redDotSize = 20;

  @override
  void initState() {
    super.initState();
    _startTargetMovement();
  }

  void _startTargetMovement() {
    targetTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        if (movingRight) {
          targetX += 0.01;
          if (targetX >= 1) movingRight = false;
        } else {
          targetX -= 0.01;
          if (targetX <= -1) movingRight = true;
        }
      });
    });
  }

  void _shootArrow() {
    if (isArrowFlying || arrowsLeft == 0) return;

    isArrowFlying = true;
    arrowY = 1;

    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        arrowY -= 0.02;
        if (arrowY <= -0.8) {
          timer.cancel();
          _checkHit();
          isArrowFlying = false;
        }
      });
    });
  }

  void _checkHit() {
    double arrowX = 0;
    double targetCenter = targetX;
    double redZoneLeft =
        targetCenter - redDotSize / MediaQuery.of(context).size.width;
    double redZoneRight =
        targetCenter + redDotSize / MediaQuery.of(context).size.width;
    double targetLeft =
        targetCenter - targetSize / MediaQuery.of(context).size.width;
    double targetRight =
        targetCenter + targetSize / MediaQuery.of(context).size.width;

    if (arrowX >= redZoneLeft && arrowX <= redZoneRight) {
      score += 5;
      // arrow is returned
    } else if (arrowX >= targetLeft && arrowX <= targetRight) {
      score += 1;
      arrowsLeft -= 1;
    } else {
      // Miss
      arrowsLeft -= 1;
    }
  }

  @override
  void dispose() {
    targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Hit the Target'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Target
          Align(
            alignment: Alignment(targetX, -0.9),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: targetSize,
                  height: targetSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: redDotSize,
                  height: redDotSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          AnimatedAlign(
            duration: const Duration(milliseconds: 10),
            alignment: Alignment(0, arrowY),
            // child: Container(
            //   width: arrowWidth,
            //   height: arrowHeight,
            //   decoration: BoxDecoration(
            //     color: Colors.green,
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            // ),
            child:
                const Icon(Icons.arrow_drop_up, color: Colors.yellow, size: 40),
          ),

          // Fire button & score
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Score: $score 🎯",
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text("Arrows Left: $arrowsLeft 🏹",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _shootArrow,
                    child: const Text('Shoot Arrow'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
