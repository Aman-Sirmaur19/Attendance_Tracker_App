import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/tab_screen.dart';
import 'data/hive_data_store.dart';
import 'models/task.dart';
import 'screens/settings_screen.dart';

late Size mq;
bool isFloatingActionButton = prefs.getBool('FloatingActionButton') ?? false;
late SharedPreferences prefs;

_initializeMobileAds() async {
  await MobileAds.instance.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  prefs = await SharedPreferences.getInstance();

  // Init Hive DB before runApp()
  await Hive.initFlutter();
  await Hive.openBox('routineImageBox');

  // Register Hive Adapter
  Hive.registerAdapter<Task>(TaskAdapter());

  // Calls theme settings
  await SettingsScreen.loadSettings();

  // Open a Box
  Box box = await Hive.openBox<Task>(HiveDataStore.boxName);

  // Automatically delete task from previous day if not done
  // box.values.forEach((task) {
  //   if (task.createdAtTime.day != DateTime.now().day) {
  //     task.delete();
  //   } else {
  //     // Do nothing
  //   }
  // });

  _initializeMobileAds();
  runApp(BaseWidget(child: const MyApp()));
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TabScreen(),
    );
  }
}
