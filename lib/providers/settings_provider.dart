import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool isFloatingActionButton;
  bool showCircularIndicator;
  Map<String, Color> selectedColorPair;

  SettingsProvider({
    required this.isFloatingActionButton,
    required this.showCircularIndicator,
    required this.selectedColorPair,
  });

  static Future<SettingsProvider> loadFromPrefs(SharedPreferences prefs) async {
    final presentColorHex = prefs.getString('presentColor') ?? '#ff2196f3';
    final absentColorHex = prefs.getString('absentColor') ?? '#ffef5350';
    return SettingsProvider(
      isFloatingActionButton: prefs.getBool('FloatingActionButton') ?? false,
      showCircularIndicator: prefs.getBool('ShowCircularIndicator') ?? true,
      selectedColorPair: {
        'present': Color(int.parse(presentColorHex.replaceFirst('#', '0xFF'))),
        'absent': Color(int.parse(absentColorHex.replaceFirst('#', '0xFF'))),
      },
    );
  }

  void setFloatingButton(bool value, SharedPreferences prefs) {
    isFloatingActionButton = value;
    prefs.setBool('FloatingActionButton', value);
    notifyListeners();
  }

  void toggleGraphStyle(SharedPreferences prefs) {
    showCircularIndicator = !showCircularIndicator;
    prefs.setBool('ShowCircularIndicator', showCircularIndicator);
    notifyListeners();
  }

  void updateColorPair(Map<String, Color> newPair, SharedPreferences prefs) {
    selectedColorPair = newPair;
    prefs.setString('presentColor',
        '#${newPair['present']!.value.toRadixString(16).padLeft(8, '0')}');
    prefs.setString('absentColor',
        '#${newPair['absent']!.value.toRadixString(16).padLeft(8, '0')}');
    notifyListeners();
  }
}
