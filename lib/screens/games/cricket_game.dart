import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../widgets/custom_banner_ad.dart';

class CricketGame extends StatefulWidget {
  const CricketGame({super.key});

  @override
  State<CricketGame> createState() => _CricketGameState();
}

// Add 'with SingleTickerProviderStateMixin' for the AnimationController
class _CricketGameState extends State<CricketGame>
    with SingleTickerProviderStateMixin {
  // --- Game State Variables ---
  int _playerScore = 0;
  int _computerScore = 0;
  int _targetScore = 0;
  String _gameMessage = "Press 'Spin' to score runs!";
  String _displayedOutcome = "Spin to Start!"; // This is the "wheel"
  bool _isGameOver = false;

  // Random number generator
  final Random _random = Random();

  // --- Wheel & Animation Variables ---
  late AnimationController _controller; // Use Flutter's AnimationController
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0.0;
  bool _isSpinning = false;
  String _finalOutcome = ""; // Stores the result before the spin finishes

  // A static, mixed list of all outcomes for the wheel
  // This list is now static and no longer shuffled.
  final List<String> _wheelOutcomes = [
    "0",
    "4",
    "Bowled",
    "Wide",
    "1",
    "Caught",
    "6",
    "LBW",
    "2",
    "No\nBall",
    "Run\nOut",
    "3",
    "Stumped"
  ];

  // List of outcomes that count as "OUT"
  // Updated to match the newlines in _wheelOutcomes
  final List<String> _outTypes = [
    "Bowled",
    "Caught",
    "LBW",
    "Run\nOut",
    "Stumped"
  ];

  // Color for the outcome text (green for runs, red for out, white for info)
  Color _runColor = Colors.white;

  // --- Game Lifecycle ---

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // 3-second spin
    );

    // Initialize with a static, non-moving animation
    _rotationAnimation = const AlwaysStoppedAnimation<double>(0.0);

    // Add a listener to update the text rapidly during the spin
    _controller.addListener(() {
      // Just call setState to trigger a repaint
      setState(() {});
    });

    // Add a status listener to process the result when the spin is complete
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          // Set the final rotation to the target
          _currentRotation = _rotationAnimation.value;
          _displayedOutcome = _finalOutcome; // Lock in the final result
          _processOutcome(_finalOutcome); // Process the game logic
        });
      }
    });

    // No longer need to shuffle here
    _resetGame();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the AnimationController
    super.dispose();
  }

  // --- Game Logic Methods ---

  /// Resets the game to its initial state and starts the computer's turn.
  void _resetGame() {
    setState(() {
      _playerScore = 0;
      _computerScore = 0;
      _targetScore = 0;
      _isGameOver = false;
      _isSpinning = false;
      _gameMessage = "Computer is batting...";
      _displayedOutcome = "Spin to Start!";
      _runColor = Colors.white;

      // Reset rotation
      _controller.reset();
      _currentRotation = 0.0;
      _rotationAnimation = const AlwaysStoppedAnimation<double>(0.0);

      // Shuffling logic removed
    });

    // Start the computer's turn after a brief delay
    Future.delayed(const Duration(milliseconds: 500), _computerTurn);
  }

  /// Simulates the computer's entire batting innings.
  void _computerTurn() {
    bool isComputerOut = false;
    int score = 0;

    // Loop until the computer is "OUT"
    // Computer's turn now also uses the static _wheelOutcomes list
    while (!isComputerOut) {
      String outcome = _wheelOutcomes[_random.nextInt(_wheelOutcomes.length)];

      if (_outTypes.contains(outcome)) {
        isComputerOut = true;
      } else if (outcome == "Wide" || outcome == "No\nBall") {
        // Updated check
        score += 1; // +1 run for extras
      } else {
        score += int.parse(outcome); // Add runs
      }
    }

    // Update the UI with the computer's score and set the target
    setState(() {
      _computerScore = score;
      _targetScore = _computerScore + 1; // Target is 1 more
      _gameMessage =
          "Computer scored $_computerScore!\nYour target: $_targetScore";
      _displayedOutcome = "Your Turn!";
    });
  }

  /// Starts the wheel spin for the player.
  void _spinWheel() {
    // Do nothing if already spinning or game is over
    if (_isSpinning || _isGameOver) return;

    setState(() {
      _isSpinning = true;
      _runColor = Colors.white; // Reset color
    });

    // Pre-determine the final outcome from the STATIC list
    int resultIndex = _random.nextInt(_wheelOutcomes.length);
    _finalOutcome = _wheelOutcomes[resultIndex];

    // --- Calculate Target Rotation ---
    // Use the static list length for sector angle
    double sectorAngle = 2 * pi / _wheelOutcomes.length;
    double oldAngle = _currentRotation;

    // The target angle aligns the *middle* of the sector with the top pointer.
    // Pointer is at 12 o'clock (which is -pi/2 radians).
    double targetSectorMiddle = (resultIndex * sectorAngle) + (sectorAngle / 2);
    // We want targetSectorMiddle + newRotation = -pi / 2
    double newAngle = (-pi / 2) - targetSectorMiddle;

    // --- FIX: Ensure the new angle is always "behind" the old angle ---
    // This makes sure the wheel always spins clockwise (negative direction)
    while (newAngle > oldAngle) {
      newAngle -= (2 * pi);
    }

    // Add 5-10 *full* spins
    double spins = (5 + _random.nextInt(6)) * (2 * pi);
    // Set the new final rotation
    _currentRotation = newAngle - spins;

    // Create the animation
    _rotationAnimation = Tween<double>(begin: oldAngle, end: _currentRotation)
        // ---------------------------------
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Nice easing
    ));
    // ---------------------------------

    // Trigger the spin animation
    _controller.forward(from: 0);
  }

  /// Processes the logic for the final spin outcome.
  void _processOutcome(String outcome) {
    setState(() {
      _displayedOutcome = outcome; // Show the final outcome
      switch (outcome) {
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "6":
          int runs = int.parse(outcome);
          _playerScore += runs;
          _runColor = Colors.lightGreenAccent;
          break;
        case "No\nBall": // Updated check
        case "Wide":
          _playerScore += 1;
          _runColor = Colors.lightGreenAccent; // Extras are also good
          break;
        // Any "OUT" type
        default:
          _runColor = Colors.red.shade400;
          _isGameOver = true;
          _checkWinner(); // Check the result as soon as the player is out
          break;
      }

      // Check for a win if the player is not out
      if (!_isGameOver && _playerScore > _targetScore) {
        _isGameOver = true;
        _checkWinner();
      }
    });
  }

  /// Checks the final game result and updates the message.
  void _checkWinner() {
    setState(() {
      // 1. Win condition: > target
      if (_playerScore > _targetScore) {
        _gameMessage =
            "YOU WON!\nYour Score: $_playerScore | Target: $_targetScore";
        // 2. Draw condition: == target
      } else if (_playerScore == _targetScore) {
        _gameMessage =
            "IT'S A DRAW!\nYourScore: $_playerScore | Target: $_targetScore";
        // 3. Lose condition: < target
      } else {
        _gameMessage =
            "YOU LOST!\nYour Score: $_playerScore | Target: $_targetScore";
      }
    });
  }

  // --- Build Method (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade800,
      bottomNavigationBar: CustomBannerAd(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added to prevent overflow on small screens
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scoreboard Card
                Card(
                  color: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreColumn("TARGET", _targetScore),
                        _buildScoreColumn("YOUR SCORE", _playerScore),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- "Spinning Wheel" Display ---
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // The spinning part
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: WheelPainter(
                          rotationAngle: _rotationAnimation.value,
                          // Use the STATIC list for the painter
                          outcomes: _wheelOutcomes,
                          outTypes: _outTypes,
                        ),
                      ),
                      // The static pointer
                      CustomPaint(
                        size: const Size(40, 40),
                        painter: PointerPainter(),
                      ),
                    ],
                  ),
                ),
                // --- End of Wheel Display ---

                const SizedBox(height: 20), // Adjusted spacing

                // Display for the final outcome
                Container(
                  height: 60,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _runColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _displayedOutcome,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _runColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Display for game status messages
                Text(
                  _gameMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20), // Increased spacing

                // Action Buttons
                ElevatedButton.icon(
                  icon: Icon(
                      _isGameOver ? Icons.replay : Icons.replay_circle_filled),
                  label: Text(_isGameOver ? "PLAY AGAIN" : "SPIN"),
                  // Disable button while spinning
                  onPressed: _isGameOver
                      ? _resetGame
                      : (_isSpinning ? null : _spinWheel),
                  style: _buttonStyle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to build a score column for the scoreboard.
  Widget _buildScoreColumn(String title, int score) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Helper method for consistent button styling.
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      shape: const StadiumBorder(),
      elevation: 5,
      // Change opacity if button is disabled (while spinning)
      disabledBackgroundColor: Colors.amber.withOpacity(0.5),
    );
  }
}

// --- Custom Painter for the Wheel ---
class WheelPainter extends CustomPainter {
  final double rotationAngle;
  final List<String> outcomes;
  final List<String> outTypes;

  WheelPainter({
    required this.rotationAngle,
    required this.outcomes,
    required this.outTypes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final sectorAngle = 2 * pi / outcomes.length;

    // Save the canvas state, translate to center, and rotate
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    for (int i = 0; i < outcomes.length; i++) {
      final startAngle = i * sectorAngle;
      final outcome = outcomes[i];

      // Determine color
      Color itemColor = Colors.green.shade600; // Default for runs
      if (outTypes.contains(outcome)) {
        itemColor = Colors.red.shade800;
      } else if (outcome == "No\nBall" || outcome == "Wide") {
        // Updated check
        itemColor = Colors.blue.shade700;
      }

      final paint = Paint()..color = itemColor;

      // Draw the arc sector
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        sectorAngle,
        true, // Use center
        paint,
      );

      // --- Draw the text ---
      final text = outcome.toUpperCase();
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.bold,
          fontSize: text.length >= 7 && !text.contains('\n')
              ? 11
              : text.length > 5
                  ? 12
                  : 14,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate position and rotation for the text
      final textAngle = startAngle + sectorAngle / 2;
      final textPosition = Offset.fromDirection(textAngle, radius * 0.75);

      // Save canvas, move to text position, rotate, and draw
      canvas.save();
      canvas.translate(textPosition.dx, textPosition.dy);

      // --- FIX: Rotate text to be radial, and flip if upside down ---
      // Check if text is on the left side of the wheel
      bool isUpsideDown = textAngle > pi / 2 && textAngle < 3 * pi / 2;
      // Base rotation is radial (textAngle + pi/2)
      // If upside down, add 'pi' (180 degrees) to flip it
      double textRotation = textAngle + (pi / 2) + (isUpsideDown ? pi : 0);
      canvas.rotate(textRotation);

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
      // --- End text drawing ---
    }

    // Restore the canvas to its original state
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when animation ticks
  }
}

// --- Custom Painter for the Pointer ---
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2 - 12, 0); // Top-left
    path.lineTo(size.width / 2 + 12, 0); // Top-right
    path.lineTo(size.width / 2, size.height / 2 + 10); // Bottom-center
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.5), 5.0, true);
    // Draw pointer
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // This pointer never changes
  }
}
