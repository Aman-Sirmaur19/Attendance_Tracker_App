import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../main.dart';
import '../../models/attendance.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/chart_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../services/notification_service.dart';
import '../settings_screen.dart';
import 'add_attendance_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  int _expandedIndex = -1;

  final _subjectController = TextEditingController();

  Future<void> _checkForUpdate() async {
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

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
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
            appBar: AppBar(
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
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) =>
                                const AddAttendanceScreen(attendance: null))),
                    tooltip: 'Add subject',
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
              ],
            ),
            bottomNavigationBar: const CustomBannerAd(),
            floatingActionButton: isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) =>
                                const AddAttendanceScreen(attendance: null))),
                    tooltip: 'Add subject',
                    child: const Icon(Icons.add))
                : null,
            drawer: const MainDrawer(),
            body: attendances.isEmpty
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Chip(
                                padding: const EdgeInsets.all(0),
                                backgroundColor: Colors.blue.shade100,
                                label: Text(
                                  DateFormat('d MMM y').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Chip(
                                padding: const EdgeInsets.all(0),
                                backgroundColor: Colors.blue.shade100,
                                label: Text(
                                  DateFormat('EEEE').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
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

                                  ///---------------------------------------------------------------
                                  final total = attendances[index].present +
                                      attendances[index].absent;
                                  double required =
                                      (total * attendances[index].requirement) -
                                          attendances[index].present * 100;
                                  required /=
                                      (100 - attendances[index].requirement);
                                  double miss =
                                      (100.0 * attendances[index].present) -
                                          (attendances[index].requirement *
                                              (total));
                                  miss /= attendances[index].requirement;
                                  final percentage =
                                      (attendances[index].present * 100) /
                                          (total);

                                  ///---------------------------------------------------------------
                                  return Dismissible(
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
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  TextButton(
                                                      child: const Text('Yes'),
                                                      onPressed: () {
                                                        Navigator.of(ctx)
                                                            .pop(true);
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
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          attendances[index]
                                                              .subject,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              letterSpacing: 1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    IconButton(
                                                      onPressed: () => Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                              builder: (_) =>
                                                                  AddAttendanceScreen(
                                                                      attendance:
                                                                          attendances[
                                                                              index]))),
                                                      tooltip: 'Edit',
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .pencil_outline,
                                                        color: Colors
                                                            .blue.shade600,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                subtitle: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: mq.height * .005),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white60,
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
                                                                color: Colors
                                                                    .white60,
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
                                                                color: Colors
                                                                    .white60,
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: mq.height *
                                                                    .005),
                                                        child: Text(
                                                            'Last updated: $time, $date',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey)),
                                                      ),
                                                      if (total != 0)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                      mq.height *
                                                                          .005),
                                                          child:
                                                              TweenAnimationBuilder(
                                                            tween: Tween<
                                                                    double>(
                                                                begin: 0,
                                                                end:
                                                                    percentage /
                                                                        100),
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            builder: (context,
                                                                    double
                                                                        value,
                                                                    child) =>
                                                                ChartBar(value),
                                                          ),
                                                        ),
                                                      if (required > 0)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                      mq.height *
                                                                          .005),
                                                          child: Text(
                                                            required <= 1
                                                                ? 'Attend 1 class'
                                                                : attendances[index]
                                                                            .requirement ==
                                                                        100
                                                                    ? "Can't miss any class"
                                                                    : 'Attend ${required.ceil()} classes in a row',
                                                            style:
                                                                const TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )
                                                      else if (miss >= 1)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                      mq.height *
                                                                          .005),
                                                          child: Text(
                                                            miss >= 2
                                                                ? 'Can miss ${miss.floor()} classes in a row'
                                                                : 'Can miss 1 class',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )
                                                      else
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                      mq.height *
                                                                          .005),
                                                          child: const Text(
                                                            "Can't miss any class",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
                                                      },
                                                      () {
                                                        setState(() {
                                                          attendances[index]
                                                              .present++;
                                                          attendances[index]
                                                                  .time =
                                                              DateTime.now()
                                                                  .toString();
                                                        });
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
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
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
                                                      },
                                                      () {
                                                        setState(() {
                                                          attendances[index]
                                                              .absent++;
                                                          attendances[index]
                                                                  .time =
                                                              DateTime.now()
                                                                  .toString();
                                                        });
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
                                                      },
                                                    ),
                                                    customButton(
                                                      'Required',
                                                      '${attendances[index].requirement} %',
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
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
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
                                                        attendances[index]
                                                            .save();
                                                        NotificationService
                                                            .setNotificationsForAttendance(
                                                                attendances[
                                                                    index]);
                                                      },
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        )),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
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
                tooltip: 'Remove',
                icon: const Icon(Icons.remove_circle_rounded,
                    color: Colors.green)),
            Text(num, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: onAdd,
                tooltip: 'Add',
                icon:
                    const Icon(Icons.add_circle_rounded, color: Colors.green)),
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
