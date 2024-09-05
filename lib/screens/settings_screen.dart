import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../main.dart';

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
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  bool _isDropdownOpen = false;

  List<Map<String, Color>> categories = [
    {'present': Colors.blue, 'absent': Colors.red[400]!},
    {'present': Colors.purple, 'absent': Colors.amber},
    {'present': Colors.green, 'absent': Colors.red[400]!},
    {'present': Colors.blue, 'absent': Colors.amber},
    {'present': Colors.purple, 'absent': Colors.red[400]!},
  ];

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/6598107759',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
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
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
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
