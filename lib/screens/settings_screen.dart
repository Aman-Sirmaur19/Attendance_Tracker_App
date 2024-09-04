import 'package:flutter/material.dart';

import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, Color>? selectedColorPair;
  bool _isDropdownOpen = false;
  List<Map<String, Color>> categories = [
    {'present': Colors.blue, 'absent': Colors.red[400]!},
    {'present': Colors.blue, 'absent': Colors.amber},
    {'present': Colors.green, 'absent': Colors.red[400]!},
    {'present': Colors.green, 'absent': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    selectedColorPair = categories[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Settings',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        children: [
          Card(
            child: SwitchListTile(
              inactiveThumbColor: Theme.of(context).colorScheme.secondary,
              inactiveTrackColor: Colors.black12,
              title: const Text(
                'Floating Button',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 18,
                ),
              ),
              value: isFloatingActionButton,
              onChanged: (newValue) {
                setState(() {
                  isFloatingActionButton = newValue;
                });
                prefs.setBool('FloatingActionButton', isFloatingActionButton);
              },
            ),
          ),
          _customColumn(),
          const SizedBox(height: 10),
          const Text(
            'More features coming soon...',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _customColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen; // Toggle dropdown visibility
            });
          },
          child: Card(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: selectedColorPair!['present'],
                              borderRadius: BorderRadius.circular(15))),
                      const SizedBox(width: 5),
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: selectedColorPair!['absent'],
                              borderRadius: BorderRadius.circular(15))),
                      Icon(
                        _isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isDropdownOpen)
          ...categories.map((value) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColorPair = value;
                  _isDropdownOpen = false;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      color: value['present'],
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 5),
                    Container(
                      color: value['absent'],
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
