import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../main.dart';
import '../../models/attendance.dart';
import '../../utils/dialogs.dart';
import '../../widgets/chart_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../services/notification_service.dart';
import '../settings_screen.dart';
import 'add_attendance_screen.dart';
import 'notes_screen.dart';

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
          _update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void _update() async {
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
              title: const Text('Attendance Tracker'),
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
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    tooltip: 'Add subject',
                    child: const Icon(Icons.add))
                : null,
            drawer: const MainDrawer(),
            body: attendances.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/books.png', width: 150),
                        const Text(
                          'Your presence matters more\nthan you think!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => const AddAttendanceScreen(
                                      attendance: null))),
                          title: 'Get started',
                        ),
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  DateFormat('d MMM y').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  DateFormat('EEEE').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
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
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(ctx)
                                                            .pop(true);
                                                      }),
                                                  TextButton(
                                                      child: Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary),
                                                      ),
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
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.red.shade800,
                                      ),
                                      padding: const EdgeInsets.only(right: 20),
                                      alignment: Alignment.centerRight,
                                      margin: const EdgeInsets.only(top: 10),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _expandedIndex = isExpanded
                                              ? -1
                                              : index; // Toggle expanded state
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                        ),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: total == 0
                                                  ? Image.asset(
                                                      'assets/images/owl.png')
                                                  : CircleAvatar(
                                                      radius: mq.width * .07,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      child: FittedBox(
                                                          child: Text(
                                                        '${percentage.floor().toStringAsFixed(0)}%',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )),
                                                    ),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                        attendances[index]
                                                            .subject,
                                                        maxLines: 2,
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
                                                            builder: (_) => NotesScreen(
                                                                attendance:
                                                                    attendances[
                                                                        index],
                                                                notes: attendances[
                                                                        index]
                                                                    .notes))),
                                                    tooltip: 'Sticky Notes',
                                                    icon: Icon(
                                                      CupertinoIcons.doc_on_doc,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.green
                                                          : Colors.lightGreen,
                                                    ),
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
                                                      color:
                                                          Colors.blue.shade600,
                                                    ),
                                                  ),
                                                ],
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
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
                                                    if (total != 0)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: mq.height *
                                                                    .005),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: mq.height *
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
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    else if (miss >= 1)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: mq.height *
                                                                    .005),
                                                        child: Text(
                                                          miss >= 2
                                                              ? 'Can miss ${miss.floor()} classes in a row'
                                                              : 'Can miss 1 class',
                                                          style: TextStyle(
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors.green
                                                                : Colors
                                                                    .lightGreen,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: mq.height *
                                                                    .005),
                                                        child: const Text(
                                                          "Can't miss any class",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    if (isExpanded)
                                                      RichText(
                                                        text: TextSpan(
                                                          text:
                                                              'Last updated: ',
                                                          style:
                                                              const TextStyle(
                                                                  letterSpacing:
                                                                      .25,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '$time, $date',
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      .75,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondaryContainer),
                                                            )
                                                          ],
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
                                                  _customButton(
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
                                                      attendances[index].save();
                                                      NotificationService
                                                          .setNotificationsForAttendance(
                                                              attendances[
                                                                  index]);
                                                    },
                                                  ),
                                                  _customButton(
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
                                                      attendances[index].save();
                                                      NotificationService
                                                          .setNotificationsForAttendance(
                                                              attendances[
                                                                  index]);
                                                    },
                                                  ),
                                                  _customButton(
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
                                                      attendances[index].save();
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
                                                      attendances[index].save();
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
                                      ),
                                    ),
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

  Widget _customButton(String name, String num, void Function()? onRemove,
      void Function()? onAdd) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                onPressed: onRemove,
                tooltip: 'Remove',
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.green
                      : Colors.lightGreen,
                )),
            Text(num, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: onAdd,
                tooltip: 'Add',
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.green
                      : Colors.lightGreen,
                )),
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
