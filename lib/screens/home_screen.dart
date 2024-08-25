import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../main.dart';
import '../models/attendance.dart';
import '../widgets/attendance_list.dart';
import '../widgets/main_drawer.dart';
import '../widgets/new_attendance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  List<Attendance> _userAttendances = [];
  late AnimationController animationController;
  bool isDrawerOpen = false;
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();

  Future<void> checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
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
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    initializeBannerAd();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    readData();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void onDrawerToggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        animationController.forward();
        drawerKey.currentState!.openSlider();
      } else {
        animationController.reverse();
        drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : const SizedBox(),
      body: SliderDrawer(
        key: drawerKey,
        isDraggable: false,
        animationDuration: 800,
        appBar: AppBar(
          leading: IconButton(
            onPressed: onDrawerToggle,
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: animationController,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'Attendance Tracker',
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _startAddNewAttendance(context),
              tooltip: 'Add subject',
              icon: const Icon(Icons.add),
            )
          ],
        ),
        slider: const MainDrawer(),
        child: AttendanceList(
          _userAttendances,
          _deleteAttendance,
          _editAttendance,
          _editSubjectName,
        ),
      ),
    );
  }

  void _showInfoAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const AlertDialog(
              title: Text('NOTE'),
              content: Text('Swipe the cards to delete!'),
            ));
  }

  void saveData() {
    List<String> attendanceListString = _userAttendances
        .map((attendance) => jsonEncode(attendance.toJson()))
        .toList();
    prefs.setStringList('myData', attendanceListString);
  }

  void readData() {
    List<String>? attendanceListString = prefs.getStringList('myData');
    if (attendanceListString != null) {
      _userAttendances = attendanceListString
          .map((attendance) => Attendance.fromJson(json.decode(attendance)))
          .toList();
    }
    setState(() {});
  }

  void _addNewAttendance(
    String subject,
    int present,
    int absent,
    int requirement,
  ) {
    final newAttendance = Attendance(
      DateTime.now().toString(),
      DateTime.now().toString(),
      subject,
      present,
      absent,
      requirement,
    );

    setState(() {
      _userAttendances.add(newAttendance);
    });
    saveData();
  }

  void _startAddNewAttendance(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (ctx) {
          return NewAttendance(_addNewAttendance);
        });
  }

  void _editSubjectName(String id, String name) {
    final index =
        _userAttendances.indexWhere((attendance) => attendance.id == id);
    if (index != -1) {
      setState(() {
        _userAttendances[index].subject = name;
      });
      saveData();
    }
  }

  void _editAttendance(
    String id,
    int present,
    int absent,
    int requirement,
  ) {
    final index =
        _userAttendances.indexWhere((attendance) => attendance.id == id);
    if (index != -1) {
      setState(() {
        _userAttendances[index].present = present;
        _userAttendances[index].absent = absent;
        _userAttendances[index].requirement = requirement;
      });
      saveData();
    }
  }

  void _deleteAttendance(String id) {
    setState(() {
      _userAttendances.removeWhere((attendance) => attendance.id == id);
    });
    saveData();
  }
}
