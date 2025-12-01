import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../utils/dialogs.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/pro_container.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/revenue_cat_provider.dart';
import 'subscriptions_screen.dart';

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
    final subscriptionProvider = Provider.of<RevenueCatProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          const CustomText(text: 'Native settings'),
          const SizedBox(height: 5),
          ListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ProContainer(),
              ],
            ),
            subtitle: Text(
                Provider.of<ThemeProvider>(context).currentThemeDescription),
            trailing: CircleAvatar(
              backgroundColor: themeMode == ThemeMode.light
                  ? Colors.orange.withOpacity(.2)
                  : themeMode == ThemeMode.dark
                      ? Colors.indigo.withOpacity(.2)
                      : Colors.lightGreen.withOpacity(.2),
              child: Icon(
                themeMode == ThemeMode.light
                    ? Icons.wb_sunny_rounded
                    : themeMode == ThemeMode.dark
                        ? Icons.nights_stay_rounded
                        : Icons.phone_android_rounded,
                color: themeMode == ThemeMode.light
                    ? Colors.orange
                    : themeMode == ThemeMode.dark
                        ? Colors.indigo
                        : Colors.lightGreen,
              ),
            ),
            onTap: () {
              if (!subscriptionProvider.isPremium) {
                context.read<NavigationProvider>().increment();
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SubscriptionsScreen()));
              } else {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (context) {
                    final themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Theme',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.orange.withOpacity(.2),
                                  child: const Icon(Icons.wb_sunny_rounded,
                                      color: Colors.orange),
                                ),
                                tileColor:
                                    Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: const Text('Light Mode'),
                                trailing: themeProvider.isLightMode
                                    ? const Icon(Icons.check,
                                        color: Colors.blue)
                                    : null,
                                onTap: () {
                                  themeProvider.setLightMode();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.indigo.withOpacity(.2),
                                  child: const Icon(Icons.nights_stay_rounded,
                                      color: Colors.indigo),
                                ),
                                tileColor:
                                    Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: const Text('Dark Mode'),
                                trailing: themeProvider.isDarkMode
                                    ? const Icon(Icons.check,
                                        color: Colors.blue)
                                    : null,
                                onTap: () {
                                  themeProvider.setDarkMode();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.lightGreen.withOpacity(.2),
                                  child: const Icon(Icons.phone_android_rounded,
                                      color: Colors.lightGreen),
                                ),
                                tileColor:
                                    Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: const Text('System (Default)'),
                                trailing: themeProvider.isSystemMode
                                    ? const Icon(Icons.check,
                                        color: Colors.blue)
                                    : null,
                                onTap: () {
                                  themeProvider.setSystemMode();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              'Notification Time Before Class',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${settingsProvider.notificationOffsetMinutes >= 60 ? (settingsProvider.notificationOffsetMinutes / 60).toInt() : settingsProvider.notificationOffsetMinutes} ${settingsProvider.notificationOffsetMinutes == 60 ? 'hour' : settingsProvider.notificationOffsetMinutes > 60 ? 'hours' : 'minutes'} before class',
            ),
            trailing: CircleAvatar(
                backgroundColor: Colors.lightGreen.withOpacity(.2),
                child:
                    Icon(CupertinoIcons.bell_fill, color: Colors.lightGreen)),
            onTap: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) {
                  final options = [15, 30, 45, 60, 120];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Notify Me Before',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 15),
                          ...options.map((min) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                tileColor:
                                    Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: Text(min == 60
                                    ? '${(min / 60).toInt()} hour'
                                    : min > 60
                                        ? '${(min / 60).toInt()} hours'
                                        : '$min minutes'),
                                trailing: settingsProvider
                                            .notificationOffsetMinutes ==
                                        min
                                    ? const Icon(Icons.check,
                                        color: Colors.blue)
                                    : null,
                                onTap: () {
                                  settingsProvider.setNotificationOffsetMinutes(
                                      min, prefs);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10),
          CustomBannerAd(),
          const SizedBox(height: 10),
          const CustomText(text: 'UI settings'),
          const SizedBox(height: 5),
          SwitchListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            inactiveThumbColor: Theme.of(context).colorScheme.secondary,
            inactiveTrackColor: Colors.black12,
            activeColor: Colors.blue,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Floating Button',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ProContainer(),
              ],
            ),
            value: settingsProvider.isFloatingActionButton,
            onChanged: (newValue) {
              if (!subscriptionProvider.isPremium) {
                context.read<NavigationProvider>().increment();
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SubscriptionsScreen()));
              } else {
                settingsProvider.setFloatingButton(newValue, prefs);
              }
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            inactiveThumbColor: Theme.of(context).colorScheme.secondary,
            inactiveTrackColor: Colors.black12,
            activeColor: Colors.blue,
            title: const Text(
              'Overall Attendance %',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Show or hide overall attendance percentage on home screen.',
              style: TextStyle(fontSize: 12),
            ),
            value: settingsProvider.showOverallAttendance,
            onChanged: (newValue) {
              settingsProvider.setShowOverallAttendance(newValue, prefs);
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            onTap: () {
              if (!subscriptionProvider.isPremium) {
                context.read<NavigationProvider>().increment();
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SubscriptionsScreen()));
              } else {
                settingsProvider.toggleGraphStyle(prefs);
              }
            },
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Graph Style',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ProContainer(),
              ],
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
            if (!Provider.of<RevenueCatProvider>(context, listen: false)
                .isPremium) {
              context.read<NavigationProvider>().increment();
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const SubscriptionsScreen()));
            } else {
              setState(() {
                _isDropdownOpen = !_isDropdownOpen;
              });
            }
          },
          child: ListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Graph Colour',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    ProContainer(),
                  ],
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
