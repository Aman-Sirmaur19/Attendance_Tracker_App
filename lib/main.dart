import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feedback/feedback.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzz;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secrets.dart';
import 'utils/theme.dart';
import 'models/task.dart';
import 'models/project.dart';
import 'models/routine.dart';
import 'models/attendance.dart';
import 'screens/tab_screen.dart';
import 'data/hive_data_store.dart';
import 'services/feedback_service.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/project_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/revenue_cat_provider.dart';

late Size mq;
late SharedPreferences prefs;

Future<void> _initializeMobileAds() async {
  await MobileAds.instance.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Secrets.configureRevenueCatSdk();
  _initializeMobileAds();
  tzz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  await NotificationService.init();

  prefs = await SharedPreferences.getInstance();

  // Init Hive DB before runApp()
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter<Attendance>(AttendanceAdapter());
  Hive.registerAdapter(RoutineAdapter());
  Hive.registerAdapter<Task>(TaskAdapter());
  // Register generated Project adapters
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ProjectSubjectAdapter());
  Hive.registerAdapter(ProjectChapterAdapter());
  Hive.registerAdapter(ProjectTopicAdapter());
  Hive.registerAdapter(ProjectSubTopicAdapter());

  // Open all the boxes
  await Hive.openBox<Attendance>(HiveDataStore.attendanceBoxName);
  await Hive.openBox<Routine>(HiveDataStore.routineBoxName);
  await Hive.openBox<Uint8List>('routineImageBox');
  await Hive.openBox<Task>(HiveDataStore.taskBoxName);

  // Open the NEW project box
  await Hive.openBox<Project>(HiveDataStore.projectBoxName);

  // Load settings from SharedPreferences into provider
  final settingsProvider = await SettingsProvider.loadFromPrefs(prefs);

  runApp(
    BetterFeedback(
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      feedbackBuilder: FeedbackService.builder,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<RevenueCatProvider>(
              create: (_) => RevenueCatProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider),
          // Add ProjectProvider
          ChangeNotifierProvider<ProjectProvider>(
              create: (_) => ProjectProvider()),
          ChangeNotifierProxyProvider<RevenueCatProvider, NavigationProvider>(
            create: (context) => NavigationProvider(
              context.read<RevenueCatProvider>(),
            ),
            update: (context, revenueCat, navigationProvider) {
              if (navigationProvider == null) {
                throw Exception("NavigationProvider is null");
              }
              navigationProvider.updateRevenueCat(revenueCat);
              return navigationProvider;
            },
          ),
        ],
        child: BaseWidget(child: const MyApp()),
      ),
    ),
  );
}

// ... rest of your main.dart code (BaseWidget, MyApp class) stays exactly the same
class BaseWidget extends InheritedWidget {
  BaseWidget({super.key, required this.child}) : super(child: child);

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeProvider.themeMode,
      home: const TabScreen(),
    );
  }
}

/*
remove print from revenue cat provider
FAQs for project

cricket
hit the hammer
 */
