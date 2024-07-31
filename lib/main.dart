import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_tracker/data/hive_data_store.dart';

import './screens/tab_screen.dart';
import 'models/task.dart';

late Size mq;
late SharedPreferences prefs;

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
