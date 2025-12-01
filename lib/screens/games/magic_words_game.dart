import 'package:flutter/material.dart';

class MagicWordsGame extends StatefulWidget {
  const MagicWordsGame({super.key});

  @override
  State<MagicWordsGame> createState() => _MagicWordsGameState();
}

class _MagicWordsGameState extends State<MagicWordsGame> {
  final List<String> wordList = [
    'apple',
    'boy',
    'cat',
    'dog',
    'egg',
    'fish',
    'gun',
    'hen',
    'ice',
    'joker'
  ];

  final Map<String, List<String>> stripMap = {
    '1': ['apple', 'boy', 'cat', 'dog', 'egg'],
    '2': ['boy', 'fish', 'gun', 'hen', 'joker'],
    '3': ['apple', 'cat', 'fish', 'ice', 'joker'],
    '4': ['apple', 'dog', 'hen', 'ice', 'joker'],
    '5': ['boy', 'cat', 'dog', 'gun', 'hen'],
    '6': ['egg', 'fish', 'gun', 'ice', 'joker'],
    '7': ['apple', 'boy', 'ice', 'hen', 'egg'],
  };

  final Map<String, String> codeToWord = {
    '1347': 'apple',
    '1257': 'boy',
    '135': 'cat',
    '145': 'dog',
    '167': 'egg',
    '236': 'fish',
    '256': 'gun',
    '2457': 'hen',
    '3467': 'ice',
    '2346': 'joker',
  };

  int currentStrip = 1;
  List<String> userYesStrips = [];
  bool showStrips = false;

  void handleAnswer(bool isYes) {
    if (isYes) userYesStrips.add(currentStrip.toString());

    if (currentStrip == 7) {
      final code = userYesStrips.join();
      final guessedWord = codeToWord[code] ?? 'Unknown word';

      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.deepPurple.shade50,
            title:
                const Text('🎩 Your Word Is:', style: TextStyle(fontSize: 20)),
            content: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: Text(
                    guessedWord,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("🔄 Try Again"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentStrip = 1;
                    userYesStrips.clear();
                    showStrips = false;
                  });
                },
              ),
            ],
          ),
        );
      });
    } else {
      setState(() {
        currentStrip++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWords = stripMap[currentStrip.toString()] ?? [];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: !showStrips
                ? Column(
                    key: const ValueKey('start'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          '🎩 Choose a word in your mind from the list:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: wordList
                            .map((word) => Chip(
                                  label: Text(
                                    word,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.pinkAccent,
                                ))
                            .toList(),
                      ),
                      const Spacer(),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => showStrips = true),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start the Magic Trick'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  )
                : Column(
                    key: ValueKey('strip$currentStrip'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Text(
                          'Strip $currentStrip: Is your word in this strip?',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: currentWords
                            .map(
                              (word) => Chip(
                                label: Text(
                                  word,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.indigo,
                              ),
                            )
                            .toList(),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => handleAnswer(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                            ),
                            child: const Text('✅ Yes'),
                          ),
                          ElevatedButton(
                            onPressed: () => handleAnswer(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.shade200,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                            ),
                            child: const Text('❌ No'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
