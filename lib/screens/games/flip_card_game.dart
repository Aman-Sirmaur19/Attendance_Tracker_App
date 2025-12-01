import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_banner_ad.dart';

class FlipCardGame extends StatefulWidget {
  const FlipCardGame({super.key});

  @override
  State<FlipCardGame> createState() => _FlipCardGameState();
}

class _FlipCardGameState extends State<FlipCardGame> {
  final List<String> _emojis = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐔',
    '🐧',
    '🐦',
    '🐤',
    '🐣',
    '🦆',
    '🦅',
    '🦉',
    '🦇',
    '🐺',
    '🐗',
    '🐴',
    '🦄',
    '🐝',
    '🪲',
    '🦋',
    '🐌',
    '🐙',
    '🦑',
    '🦀',
  ];

  late List<_CardModel> _cards;
  _CardModel? _firstFlipped;
  bool _wait = false;

  bool _isTwoPlayer = false;
  int _currentPlayer = 1;
  int _player1Score = 0;
  int _player2Score = 0;

  String _difficulty = 'Easy';

  int get _pairCount {
    switch (_difficulty) {
      case 'Medium':
        return 18;
      case 'Hard':
        return 35;
      default:
        return 12;
    }
  }

  int get _crossAxisCount {
    switch (_difficulty) {
      case 'Medium':
        return 6;
      case 'Hard':
        return 7;
      default:
        return 4;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final selectedEmojis = _emojis.take(_pairCount).toList();
    final pairs = [...selectedEmojis, ...selectedEmojis]..shuffle(Random());
    _cards = List.generate(pairs.length, (index) => _CardModel(pairs[index]));
    _firstFlipped = null;
    _wait = false;
    _currentPlayer = 1;
    _player1Score = 0;
    _player2Score = 0;
  }

  void _onCardTap(int index) {
    if (_wait || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlipped == null) {
      _firstFlipped = _cards[index];
    } else {
      _wait = true;
      final secondCard = _cards[index];

      if (_firstFlipped!.emoji == secondCard.emoji) {
        setState(() {
          _firstFlipped!.isMatched = true;
          secondCard.isMatched = true;

          if (_isTwoPlayer) {
            if (_currentPlayer == 1) {
              _player1Score++;
            } else {
              _player2Score++;
            }
          }
        });

        _firstFlipped = null;
        _wait = false;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _firstFlipped!.isFlipped = false;
            secondCard.isFlipped = false;
            _firstFlipped = null;
            _wait = false;

            if (_isTwoPlayer) {
              _currentPlayer = _currentPlayer == 1 ? 2 : 1;
            }
          });
        });
      }
    }
  }

  void _resetGame() {
    setState(() => _initializeGame());
  }

  void _openSettingsDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2 Players:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: _isTwoPlayer,
                    activeColor: Colors.green,
                    activeTrackColor: Colors.lightGreen.shade200,
                    onChanged: (value) {
                      setState(() {
                        _isTwoPlayer = value;
                        _resetGame();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Difficulty:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  DropdownButton<String>(
                    value: _difficulty,
                    borderRadius: BorderRadius.circular(10),
                    items: ['Easy', 'Medium', 'Hard']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _difficulty = value;
                          _resetGame();
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Flip Cards'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetGame,
            tooltip: 'Reset Game',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.gear_solid, size: 22),
            onPressed: _openSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: Column(
        children: [
          if (_isTwoPlayer)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _playerScore('Player 1', _player1Score,
                      isActive: _currentPlayer == 1),
                  _playerScore('Player 2', _player2Score,
                      isActive: _currentPlayer == 2),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final card = _cards[index];
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: card.isFlipped || card.isMatched
                          ? Colors.white
                          : Colors.deepPurple.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      card.isFlipped || card.isMatched ? card.emoji : '?',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerScore(String name, int score, {required bool isActive}) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
        Text('Score: $score', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _CardModel {
  final String emoji;
  bool isFlipped = false;
  bool isMatched = false;

  _CardModel(this.emoji);
}
