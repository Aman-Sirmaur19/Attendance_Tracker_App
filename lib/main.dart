import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzz;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme.dart';
import 'models/task.dart';
import 'models/attendance.dart';
import 'screens/tab_screen.dart';
import 'data/hive_data_store.dart';
import 'services/ad_manager.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';

late Size mq;
late SharedPreferences prefs;

_initializeMobileAds() async {
  await MobileAds.instance.initialize();
  AdManager().initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  _initializeMobileAds();
  tzz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  await NotificationService.init();

  prefs = await SharedPreferences.getInstance();

  // Init Hive DB before runApp()
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter<Attendance>(AttendanceAdapter());
  Hive.registerAdapter<Task>(TaskAdapter());

  // Open all the boxes
  await Hive.openBox<Attendance>(HiveDataStore.attendanceBoxName);
  await Hive.openBox('routineImageBox');
  await Hive.openBox<Task>(HiveDataStore.taskBoxName);

  // Load settings from SharedPreferences into provider
  final settingsProvider = await SettingsProvider.loadFromPrefs(prefs);

  runApp(
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => settingsProvider,
      child: BaseWidget(child: const MyApp()),
    ),
  );
}

// This inherited widget provides us with a convenient way to pass data between
// widgets. While developing an app we will need some data from parent's widgets
// or grant parent widgets or maybe beyond that.
class BaseWidget extends InheritedWidget {
  BaseWidget({Key? key, required this.child}) : super(key: key, child: child);

  final HiveDataStore dataStore = HiveDataStore();
  final Widget child;

  static BaseWidget of(BuildContext context) {
    final BaseWidget? result =
        context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    assert(result != null, 'No BaseWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(BaseWidget old) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendanceTracker',
      theme: lightMode,
      darkTheme: darkMode,
      home: const TabScreen(),
    );
  }
}
