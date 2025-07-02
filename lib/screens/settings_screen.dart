import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/dialogs.dart';
import '../widgets/custom_banner_ad.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
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
      floatingActionButton: settingsProvider.isFloatingActionButton
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
          SwitchListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            value: settingsProvider.isFloatingActionButton,
            onChanged: (newValue) {
              settingsProvider.setFloatingButton(newValue, prefs);
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            onTap: () {
              settingsProvider.toggleGraphStyle(prefs);
            },
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              'Graph Style',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 18,
              ),
            ),
            subtitle: const Text(
              'Tap to switch between Bar Graph and Circular Graph.',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              settingsProvider.showCircularIndicator
                  ? Icons.donut_large_rounded
                  : CupertinoIcons.minus,
              size: 30,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 10),
          _customColumn(settingsProvider),
        ],
      ),
    );
  }

  Widget _customColumn(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: ListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        color: settingsProvider.selectedColorPair['present'],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: settingsProvider.selectedColorPair['absent'],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
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
        if (_isDropdownOpen)
          settingsProvider.showCircularIndicator
              ? GridView.count(
                  padding: const EdgeInsets.all(10),
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                  children: categories.map((value) {
                    return GestureDetector(
                      onTap: () {
                        settingsProvider.updateColorPair(value, prefs);
                        setState(() => _isDropdownOpen = false);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        padding: const EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          value: 0.75,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation(
                              value['present'] ?? Colors.blue),
                          backgroundColor: value['absent'] ?? Colors.redAccent,
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: categories.map((value) {
                    return GestureDetector(
                      onTap: () {
                        settingsProvider.updateColorPair(value, prefs);
                        setState(() => _isDropdownOpen = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: SizedBox(
                          width: mq.width,
                          height: mq.width * .05,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey, width: 1.0),
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
                ),
      ],
    );
  }
}
