import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/dialogs.dart';
import '../widgets/custom_banner_ad.dart';

class SettingsScreen extends StatefulWidget {
  static Map<String, Color> selectedColorPair = {
    'present': Colors.blue,
    'absent': Colors.red[400]!,
  };

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  static Future<void> loadSettings() async {
    final presentColorHex = prefs.getString('presentColor') ?? '#ff2196f3';
    final absentColorHex = prefs.getString('absentColor') ?? '#ffef5350';

    selectedColorPair = {
      'present': Color(int.parse(presentColorHex.replaceFirst('#', '0xFF'))),
      'absent': Color(int.parse(absentColorHex.replaceFirst('#', '0xFF'))),
    };
  }

  static Future<void> _saveSettings(Map<String, Color> colorPair) async {
    final presentColorHex =
        colorPair['present']!.value.toRadixString(16).padLeft(8, '0');
    final absentColorHex =
        colorPair['absent']!.value.toRadixString(16).padLeft(8, '0');

    await prefs.setString('presentColor', '#$presentColorHex');
    await prefs.setString('absentColor', '#$absentColorHex');
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDropdownOpen = false;

  List<Map<String, Color>> categories = [
    {'present': Colors.blue, 'absent': Colors.red[400]!},
    {'present': Colors.deepPurpleAccent, 'absent': Colors.amber.shade600},
    {'present': Colors.lightGreen, 'absent': Colors.red[400]!},
    {'present': Colors.blue, 'absent': Colors.amber.shade600},
    {'present': Colors.deepPurpleAccent, 'absent': Colors.redAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      floatingActionButton: isFloatingActionButton
          ? FloatingActionButton(
              onPressed: () => Dialogs.showSnackBar(
                  context, 'Already enabled in all pages!'),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              tooltip: 'Floating button!',
              child: const Icon(Icons.add))
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        children: [
          Card(
            child: SwitchListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              inactiveThumbColor: Theme.of(context).colorScheme.secondary,
              inactiveTrackColor: Colors.black12,
              activeColor: Colors.blue,
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
                              color:
                                  SettingsScreen.selectedColorPair['present'],
                              borderRadius: BorderRadius.circular(15))),
                      const SizedBox(width: 5),
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: SettingsScreen.selectedColorPair['absent'],
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
                  SettingsScreen.selectedColorPair = value;
                  _isDropdownOpen = false;
                });
                SettingsScreen._saveSettings(value);
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
                child: SizedBox(
                  width: mq.width,
                  height: mq.width * .05,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          color: value['absent'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: .75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: value['present'],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
