import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_banner_ad.dart';

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key});

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  // Game dimensions
  final int _numberInEachRow = 9;
  final int _numberOfSquares = 9 * 9;

  // Game settings
  // Standard 9x9 grid has 10 bombs.
  // To make the game harder, you can increase this number (e.g., 15 or 20).
  final int _numberOfBombs = 10;

  // Game state
  bool _bombsRevealed = false;
  bool _firstClick = true;

  // [ number of bombs around, revealed = true / false ]
  final List<List<dynamic>> _squareStatus = [];

  // bomb locations (will be generated randomly)
  List<int> _bombLocation = [];

  // Timer variables
  Timer? _timer;
  int _timerSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _stopTimer(); // Ensure timer is cancelled when widget is disposed
    super.dispose();
  }

  void _initializeGame() {
    // Clear bombs
    _bombLocation.clear();

    // Reset game state
    _bombsRevealed = false;
    _firstClick = true;
    _timerSeconds = 0;

    // Reset all squares
    _squareStatus.clear();
    for (int i = 0; i < _numberOfSquares; i++) {
      _squareStatus.add([0, false]);
    }
    // Bombs and scanning will happen on the first click
  }

  void _generateBombs(int firstClickIndex) {
    // Clear any existing bombs
    _bombLocation.clear();
    final random = Random();

    // Add bombs randomly
    while (_bombLocation.length < _numberOfBombs) {
      int newBombIndex = random.nextInt(_numberOfSquares);

      // Ensure the new bomb isn't the first clicked square
      // and isn't already a bomb
      if (newBombIndex != firstClickIndex &&
          !_bombLocation.contains(newBombIndex)) {
        _bombLocation.add(newBombIndex);
      }
    }
  }

  void _handleFirstClick(int index) {
    if (_firstClick) {
      setState(() {
        _generateBombs(index); // Generate bombs, avoiding the first click
        _scanBombs(); // Now, scan all bomb counts
        _firstClick = false;
        _startTimer(); // Start the timer
      });
    }
  }

  // --- Timer Methods ---
  void _startTimer() {
    _stopTimer(); // Stop any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timerSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  // ---------------------

  void _restartGame() {
    _stopTimer();
    setState(() {
      _initializeGame();
    });
  }

  void _revealBoxNumbers(int index) {
    // reveal current box if it is a number 1, 2, 3 etc.
    if (_squareStatus[index][0] != 0) {
      setState(() {
        _squareStatus[index][1] = true;
      });
    } else if (_squareStatus[index][0] == 0) {
      // reveal current box, and the 8 surrounding boxes, unless you are on a wall
      setState(() {
        // reveal current box
        _squareStatus[index][1] = true;
        // reveal left box (unless we are currently on the left wall)
        if (index % _numberInEachRow != 0) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index - 1][0] == 0 &&
              _squareStatus[index - 1][1] == false) {
            _revealBoxNumbers(index - 1);
          }
          // reveal left box
          _squareStatus[index - 1][1] = true;
        }
        // reveal top-left box (unless we are currently on the top row or left wall)
        if (index % _numberInEachRow != 0 && index >= _numberInEachRow) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index - 1 - _numberInEachRow][0] == 0 &&
              _squareStatus[index - 1 - _numberInEachRow][1] == false) {
            _revealBoxNumbers(index - 1 - _numberInEachRow);
          }
          _squareStatus[index - 1 - _numberInEachRow][1] = true;
        }
        // reveal top box (unless we are currently on the top row)
        if (index >= _numberInEachRow) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index - _numberInEachRow][0] == 0 &&
              _squareStatus[index - _numberInEachRow][1] == false) {
            _revealBoxNumbers(index - _numberInEachRow);
          }
          _squareStatus[index - _numberInEachRow][1] = true;
        }
        // reveal top-right box (unless we are currently on the top row or right wall)
        if (index >= _numberInEachRow &&
            index % _numberInEachRow != _numberInEachRow - 1) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index + 1 - _numberInEachRow][0] == 0 &&
              _squareStatus[index + 1 - _numberInEachRow][1] == false) {
            _revealBoxNumbers(index + 1 - _numberInEachRow);
          }
          _squareStatus[index + 1 - _numberInEachRow][1] = true;
        }
        // reveal right box (unless we are currently on the right wall)
        if (index % _numberInEachRow != _numberInEachRow - 1) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index + 1][0] == 0 &&
              _squareStatus[index + 1][1] == false) {
            _revealBoxNumbers(index + 1);
          }
          _squareStatus[index + 1][1] = true;
        }
        // reveal bottom-right box (unless we are currently on the bottom row or right wall)
        if (index < _numberOfSquares - _numberInEachRow &&
            index % _numberInEachRow != _numberInEachRow - 1) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index + 1 + _numberInEachRow][0] == 0 &&
              _squareStatus[index + 1 + _numberInEachRow][1] == false) {
            _revealBoxNumbers(index + 1 + _numberInEachRow);
          }
          _squareStatus[index + 1 + _numberInEachRow][1] = true;
        }
        // reveal bottom box (unless we are currently on the bottom row)
        if (index < _numberOfSquares - _numberInEachRow) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index + _numberInEachRow][0] == 0 &&
              _squareStatus[index + _numberInEachRow][1] == false) {
            _revealBoxNumbers(index + _numberInEachRow);
          }
          _squareStatus[index + _numberInEachRow][1] = true;
        }
        // reveal bottom-left box (unless we are currently on the bottom row or left wall)
        if (index < _numberOfSquares - _numberInEachRow &&
            index % _numberInEachRow != 0) {
          // if next box isn't revealed yet and it is a 0, then recurse
          if (_squareStatus[index - 1 + _numberInEachRow][0] == 0 &&
              _squareStatus[index - 1 + _numberInEachRow][1] == false) {
            _revealBoxNumbers(index - 1 + _numberInEachRow);
          }
          _squareStatus[index - 1 + _numberInEachRow][1] = true;
        }
      });
    }
  }

  void _scanBombs() {
    for (int i = 0; i < _numberOfSquares; i++) {
      // initially, there are no bombs around
      int numberOfBombsAround = 0;

      // check left
      if (_bombLocation.contains(i - 1) && (i % _numberInEachRow != 0)) {
        numberOfBombsAround++;
      }

      // check top-left
      if (_bombLocation.contains(i - 1 - _numberInEachRow) &&
          (i % _numberInEachRow != 0) &&
          (i >= _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // check top
      if (_bombLocation.contains(i - _numberInEachRow) &&
          (i >= _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // check top-right
      if (_bombLocation.contains(i + 1 - _numberInEachRow) &&
          (i % _numberInEachRow != _numberInEachRow - 1) &&
          (i >= _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // check right
      if (_bombLocation.contains(i + 1) &&
          (i % _numberInEachRow != _numberInEachRow - 1)) {
        numberOfBombsAround++;
      }

      // check bottom-right
      if (_bombLocation.contains(i + 1 + _numberInEachRow) &&
          (i % _numberInEachRow != _numberInEachRow - 1) &&
          (i < _numberOfSquares - _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // check bottom
      if (_bombLocation.contains(i + _numberInEachRow) &&
          (i < _numberOfSquares - _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // check bottom-left
      if (_bombLocation.contains(i - 1 + _numberInEachRow) &&
          (i % _numberInEachRow != 0) &&
          (i < _numberOfSquares - _numberInEachRow)) {
        numberOfBombsAround++;
      }

      // add total number of bombs around to square status
      // No setState here, as this is called within another setState
      _squareStatus[i][0] = numberOfBombsAround;
    }
  }

  void _playerLost() {
    _stopTimer(); // Stop the timer on loss
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            actionsAlignment: MainAxisAlignment.spaceAround,
            title: Center(
              child: Text(
                'YOU LOST :(',
                style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              'Time: $_timerSeconds seconds',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                color: Colors.white,
                child: Text(
                  'Exit',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartGame();
                },
                color: Colors.white,
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        });
  }

  void _playerWon() {
    _stopTimer(); // Stop the timer on win
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            actionsAlignment: MainAxisAlignment.spaceAround,
            title: Center(
              child: Text(
                'YOU WON :)',
                style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              'Your time: $_timerSeconds seconds!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                color: Colors.white,
                child: Text(
                  'Exit',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartGame();
                },
                color: Colors.white,
                child: Text(
                  'Restart',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        });
  }

  void _checkWinner() {
    // check how many boxes yet to reveal
    int unrevealedBoxes = 0;
    for (int i = 0; i < _numberOfSquares; i++) {
      if (_squareStatus[i][1] == false) {
        unrevealedBoxes++;
      }
    }

    // if this number is the same as the number of bombs, then player wins
    if (unrevealedBoxes == _bombLocation.length) {
      _playerWon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: CustomBannerAd(),
      body: Column(
        children: [
          // game stats and menu
          Container(
            height: 150,
            color: Colors.grey.shade400, // Adjusted color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Number of bombs
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _numberOfBombs.toString(), // Use the variable
                      style: TextStyle(fontSize: 40),
                    ),
                    Text('BOMB', style: TextStyle(letterSpacing: 5)),
                  ],
                ),
                // Restart button
                Card(
                  color: Colors.grey.shade700,
                  elevation: 5,
                  child: IconButton(
                    onPressed: _restartGame,
                    tooltip: 'Restart',
                    icon: Icon(
                      CupertinoIcons.refresh,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Timer
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_timerSeconds.toString(), // Use timer variable
                        style: TextStyle(fontSize: 40)),
                    Text('TIME', style: TextStyle(letterSpacing: 5)),
                  ],
                ),
              ],
            ),
          ),

          // grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(left: 10, right: 10, top: 30),
              physics: NeverScrollableScrollPhysics(),
              itemCount: _numberOfSquares,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _numberInEachRow),
              itemBuilder: (context, index) {
                // Check if this index is a bomb
                if (_bombLocation.contains(index)) {
                  return Bomb(
                    revealed: _bombsRevealed,
                    onTap: () {
                      // Can't click bomb on first click
                      if (_firstClick) return;
                      // Player clicked a bomb
                      setState(() {
                        _bombsRevealed = true;
                      });
                      _playerLost();
                    },
                  );
                } else {
                  // Not a bomb
                  return NumberedBox(
                    index: _squareStatus[index][0],
                    revealed: _squareStatus[index][1],
                    onTap: () {
                      // If it's the first click, initialize the game
                      if (_firstClick) {
                        _handleFirstClick(index);
                      }

                      // If already revealed, do nothing
                      if (_squareStatus[index][1]) return;

                      // reveal current box
                      _revealBoxNumbers(index);
                      // check if player won
                      _checkWinner();
                    },
                  );
                }
              },
            ),
          ),

          // branding
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'MINESWEEPER',
              style: TextStyle(
                letterSpacing: 6,
                color: Colors.grey.shade600, // Adjusted color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberedBox extends StatelessWidget {
  final int index;
  final bool revealed;
  final void Function() onTap;

  const NumberedBox({
    super.key,
    required this.index,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(1.5), // Slightly more margin
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: revealed ? Colors.grey.shade300 : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(4),
          boxShadow: revealed
              ? [] // No shadow if revealed
              : [
                  // Simple shadow for unrevealed boxes
                  BoxShadow(
                    color: Colors.grey.shade700,
                    offset: Offset(2, 2),
                    blurRadius: 1,
                  )
                ],
        ),
        child: Text(
          revealed ? (index == 0 ? '' : index.toString()) : '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16, // Slightly larger text
            color: index == 1
                ? Colors.blue.shade800
                : index == 2
                    ? Colors.green.shade800
                    : index == 3
                        ? Colors.red.shade800
                        : Colors.purple.shade800,
          ),
        ),
      ),
    );
  }
}

class Bomb extends StatelessWidget {
  final bool revealed;
  final void Function() onTap;

  const Bomb({super.key, required this.revealed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(1.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: revealed ? Colors.red.shade700 : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(4),
          boxShadow: revealed
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade700,
                    offset: Offset(2, 2),
                    blurRadius: 1,
                  )
                ],
        ),
        child: revealed
            ? Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 20)
            : Text(
                '', // Don't show anything until revealed
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
