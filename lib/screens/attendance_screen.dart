import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../models/attendance.dart';
import '../widgets/chart_bar.dart';
import '../widgets/dialogs.dart';
import '../widgets/main_drawer.dart';
import '../widgets/new_attendance.dart';
import 'settings_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  late AnimationController animationController;
  bool isDrawerOpen = false;
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();
  int _expandedIndex = -1;
  int _editIndex = -1;

  final _subjectController = TextEditingController();

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
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
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
    final base = BaseWidget.of(context);
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToAttendance(),
        builder: (ctx, Box<Attendance> box, Widget? child) {
          List<Attendance> attendances = box.values.toList();
          attendances.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Scaffold(
            bottomNavigationBar: isBannerLoaded
                ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
                : const SizedBox(),
            floatingActionButton: isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () => _startAddNewAttendance(context),
                    tooltip: 'Add subject',
                    child: const Icon(Icons.add))
                : null,
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
                  if (!isFloatingActionButton)
                    IconButton(
                      onPressed: () => _startAddNewAttendance(context),
                      tooltip: 'Add subject',
                      icon: const Icon(Icons.add),
                    )
                ],
              ),
              slider: const MainDrawer(),
              child: attendances.isEmpty
                  ? Center(
                      child: Stack(
                        children: <Widget>[
                          const Positioned(
                            top: 50,
                            left: 0,
                            right: 0,
                            child: Text(
                              'No subjects added yet!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Lottie.asset('assets/lottie/books.json'),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: attendances.length,
                          itemBuilder: (ctx, index) {
                            // _subjectController.text = widget.attendances[index].subject;
                            final isExpanded = _expandedIndex == index;
                            final DateTime dateTime =
                                DateTime.parse(attendances[index].time);
                            final String date =
                                DateFormat.yMMMd().format(dateTime);
                            final String time =
                                DateFormat('hh:mm a').format(dateTime);

                            final isEdit = _editIndex == index;

                            ///---------------------------------------------------------------
                            final total = attendances[index].present +
                                attendances[index].absent;
                            double required =
                                (total * attendances[index].requirement) -
                                    attendances[index].present * 100;
                            required /= (100 - attendances[index].requirement);
                            double miss = (100.0 * attendances[index].present) -
                                (attendances[index].requirement * (total));
                            miss /= attendances[index].requirement;
                            final percentage =
                                (attendances[index].present * 100) / (total);

                            ///---------------------------------------------------------------
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Dismissible(
                                key: ValueKey(attendances[index].id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) {
                                  return showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Are you sure?'),
                                      content: const Text(
                                          'Do you want to delete this?'),
                                      actions: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                  child: const Text('Yes'),
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop(true);
                                                  }),
                                              TextButton(
                                                  child: const Text('No'),
                                                  onPressed: () {
                                                    Navigator.of(ctx)
                                                        .pop(false);
                                                  }),
                                            ])
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  base.dataStore.deleteAttendance(
                                      attendance: attendances[index]);
                                  setState(() {
                                    if (_expandedIndex == index) {
                                      _expandedIndex = -1;
                                    } else if (_expandedIndex > index) {
                                      _expandedIndex--;
                                    }
                                    Dialogs.showSnackBar(context,
                                        'Attendance deleted successfully!');
                                  });
                                },
                                background: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 4,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                    elevation: 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _expandedIndex = isExpanded
                                              ? -1
                                              : index; // Toggle expanded state
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: total == 0
                                                ? Image.asset(
                                                    'assets/images/owl.png')
                                                : CircleAvatar(
                                                    radius: mq.width * .07,
                                                    child: FittedBox(
                                                        child: Text(
                                                            '${percentage.floor().toStringAsFixed(0)}%')),
                                                  ),
                                            title: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  isEdit
                                                      ? SizedBox(
                                                          width: mq.width * .4,
                                                          child: TextField(
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            autofocus: true,
                                                            controller:
                                                                _subjectController,
                                                          ),
                                                        )
                                                      : Text(
                                                          attendances[index]
                                                              .subject,
                                                          style: const TextStyle(
                                                              letterSpacing: 1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  isEdit
                                                      ? IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              if (_subjectController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  _subjectController
                                                                          .text
                                                                          .trim() !=
                                                                      attendances[
                                                                              index]
                                                                          .subject) {
                                                                attendances[index]
                                                                        .subject =
                                                                    _subjectController
                                                                        .text
                                                                        .trim();
                                                              }
                                                              attendances[index]
                                                                  .save();
                                                              _editIndex = isEdit
                                                                  ? -1
                                                                  : index; // Toggle expanded state
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.save))
                                                      : IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _subjectController
                                                                      .text =
                                                                  attendances[
                                                                          index]
                                                                      .subject;
                                                              _editIndex = isEdit
                                                                  ? -1
                                                                  : index; // Toggle expanded state
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.edit))
                                                ],
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: EdgeInsets.only(
                                                  top: mq.height * .005),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white60,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Text(
                                                            'Attended: ${attendances[index].present}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SettingsScreen
                                                                        .selectedColorPair[
                                                                    'present'])),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white60,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Text(
                                                            'Missed: ${attendances[index].absent}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: SettingsScreen
                                                                        .selectedColorPair[
                                                                    'absent'])),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white60,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Text(
                                                            'Req.: ${attendances[index].requirement} %',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .blueGrey)),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: mq.height * .005),
                                                    child: Text(
                                                        'Last updated: $time, $date',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.grey)),
                                                  ),
                                                  if (total != 0)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              mq.height * .005),
                                                      child:
                                                          TweenAnimationBuilder(
                                                        tween: Tween<double>(
                                                            begin: 0,
                                                            end: percentage /
                                                                100),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        builder: (context,
                                                                double value,
                                                                child) =>
                                                            ChartBar(value),
                                                      ),
                                                    ),
                                                  if (required > 0)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              mq.height * .005),
                                                      child: Text(
                                                        required <= 1
                                                            ? 'Attend 1 class'
                                                            : attendances[index]
                                                                        .requirement ==
                                                                    100
                                                                ? "Can't miss any class"
                                                                : 'Attend ${required.ceil()} classes in a row',
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  else if (miss >= 1)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              mq.height * .005),
                                                      child: Text(
                                                        miss >= 2
                                                            ? 'Can miss ${miss.floor()} classes in a row'
                                                            : 'Can miss 1 class',
                                                        style: const TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              mq.height * .005),
                                                      child: const Text(
                                                        "Can't miss any class",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isExpanded)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                customButton(
                                                  'Attended',
                                                  '${attendances[index].present}',
                                                  () {
                                                    setState(() {
                                                      if (attendances[index]
                                                              .present !=
                                                          0) {
                                                        attendances[index]
                                                            .present--;
                                                        attendances[index]
                                                                .time =
                                                            DateTime.now()
                                                                .toString();
                                                      }
                                                    });
                                                    attendances[index].save();
                                                  },
                                                  () {
                                                    setState(() {
                                                      attendances[index]
                                                          .present++;
                                                      attendances[index].time =
                                                          DateTime.now()
                                                              .toString();
                                                    });
                                                    attendances[index].save();
                                                  },
                                                ),
                                                customButton(
                                                  'Missed',
                                                  '${attendances[index].absent}',
                                                  () {
                                                    setState(() {
                                                      if (attendances[index]
                                                              .absent !=
                                                          0) {
                                                        attendances[index]
                                                            .absent--;
                                                        attendances[index]
                                                                .time =
                                                            DateTime.now()
                                                                .toString();
                                                      }
                                                    });
                                                    attendances[index].save();
                                                  },
                                                  () {
                                                    setState(() {
                                                      attendances[index]
                                                          .absent++;
                                                      attendances[index].time =
                                                          DateTime.now()
                                                              .toString();
                                                    });
                                                    attendances[index].save();
                                                  },
                                                ),
                                                customButton(
                                                  'Required',
                                                  '${attendances[index].requirement}%',
                                                  () {
                                                    setState(() {
                                                      if (attendances[index]
                                                              .requirement !=
                                                          0) {
                                                        attendances[index]
                                                            .requirement -= 5;
                                                        attendances[index]
                                                                .time =
                                                            DateTime.now()
                                                                .toString();
                                                      }
                                                    });
                                                    attendances[index].save();
                                                  },
                                                  () {
                                                    setState(() {
                                                      if (attendances[index]
                                                              .requirement <
                                                          100) {
                                                        attendances[index]
                                                            .requirement += 5;
                                                        attendances[index]
                                                                .time =
                                                            DateTime.now()
                                                                .toString();
                                                      }
                                                    });
                                                    attendances[index].save();
                                                  },
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    )),
                              ),
                            );
                          }),
                    ),
            ),
          );
        });
  }

  void _startAddNewAttendance(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (ctx) {
          return const NewAttendance(attendance: null);
        });
  }

  Widget customButton(String name, String num, void Function()? onRemove,
      void Function()? onAdd) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle, color: Colors.green)),
            Text(num, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle, color: Colors.green)),
          ],
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }
}
