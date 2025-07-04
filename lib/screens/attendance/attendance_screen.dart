import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../main.dart';
import '../../utils/dialogs.dart';
import '../../models/attendance.dart';
import '../../services/ad_manager.dart';
import '../../services/notification_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/chart_bar.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_elevated_button.dart';
import '../dashboard_screen.dart';
import 'notes_screen.dart';
import 'add_attendance_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  // bool _migrationChecked = false;
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

  // Future<void> _migrateAttendancesIfNeeded(Box<Attendance> box) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final migrated = prefs.getBool('attendance_migrated') ?? false;
  //   if (!migrated) {
  //     for (var att in box.values) {
  //       try {
  //         if (!att.toMap().containsKey('isLab')) {
  //           att.isLab = false;
  //           await att.save();
  //         }
  //       } catch (e) {
  //         att.isLab = false;
  //         await att.save();
  //       }
  //     }
  //     await prefs.setBool('attendance_migrated', true);
  //   }
  // }

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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToAttendance(),
        builder: (ctx, Box<Attendance> box, Widget? child) {
          // if (!_migrationChecked) {
          //   _migrateAttendancesIfNeeded(box);
          //   _migrationChecked = true;
          // }
          List<Attendance> attendances = box.values.toList();
          for (var att in attendances) {
            if (att.isLab == null) {
              att.isLab = false;
              att.save();
            }
          }
          attendances.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => AdManager()
                    .navigateWithAd(context, const DashboardScreen()),
                tooltip: 'Dashboard',
                icon: const Icon(CupertinoIcons.square_grid_2x2),
              ),
              title: const Text('Attendance Tracker'),
              actions: [
                if (!settingsProvider.isFloatingActionButton)
                  IconButton(
                    onPressed: () => AdManager().navigateWithAd(
                        context, const AddAttendanceScreen(attendance: null)),
                    tooltip: 'Add subject',
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
              ],
            ),
            bottomNavigationBar: const CustomBannerAd(),
            floatingActionButton: settingsProvider.isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () => AdManager().navigateWithAd(
                        context, const AddAttendanceScreen(attendance: null)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    tooltip: 'Add subject',
                    child: const Icon(Icons.add))
                : null,
            body: attendances.isEmpty
                ? _emptyWidget()
                : DefaultTabController(
                    length: 2,
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
                          Container(
                            height: 30,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              dividerColor: Colors.transparent,
                              labelColor:
                                  Theme.of(context).colorScheme.secondary,
                              unselectedLabelColor:
                                  Theme.of(context).colorScheme.onSurface,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding: const EdgeInsets.all(0),
                              indicatorPadding: const EdgeInsets.all(3),
                              tabs: const [
                                Tab(text: "Theory"),
                                Tab(text: "Lab"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildAttendanceList(
                                  base,
                                  attendances
                                      .where((a) => a.isLab == false)
                                      .toList(),
                                ),
                                _buildAttendanceList(
                                  base,
                                  attendances
                                      .where((a) => a.isLab == true)
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  Widget _emptyWidget() {
    return Center(
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
            onPressed: () => AdManager().navigateWithAd(
                context, const AddAttendanceScreen(attendance: null)),
            title: 'Get started',
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(BaseWidget base, List<Attendance> attendances) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    if (attendances.isEmpty) {
      return _emptyWidget();
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: attendances.length,
      itemBuilder: (ctx, index) {
        // _subjectController.text = widget.attendances[index].subject;
        final isExpanded = _expandedIndex == index;
        final DateTime dateTime = DateTime.parse(attendances[index].time);
        final String date = DateFormat.yMMMd().format(dateTime);
        final String time = DateFormat('hh:mm a').format(dateTime);

        ///---------------------------------------------------------------
        final total = attendances[index].present + attendances[index].absent;
        double required = (total * attendances[index].requirement) -
            attendances[index].present * 100;
        required /= (100 - attendances[index].requirement);
        double miss = (100.0 * attendances[index].present) -
            (attendances[index].requirement * (total));
        miss /= attendances[index].requirement;
        final percentage = (attendances[index].present * 100) / (total);

        ///---------------------------------------------------------------
        return Dismissible(
          key: ValueKey(attendances[index].id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to delete this?'),
                actions: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            }),
                        TextButton(
                            child: Text(
                              'No',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            }),
                      ])
                ],
              ),
            );
          },
          onDismissed: (direction) {
            base.dataStore.deleteAttendance(attendance: attendances[index]);
            setState(() {
              if (_expandedIndex == index) {
                _expandedIndex = -1;
              } else if (_expandedIndex > index) {
                _expandedIndex--;
              }
              Dialogs.showSnackBar(context, 'Attendance deleted successfully!');
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
              Icons.delete_rounded,
              color: Colors.white,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex =
                    isExpanded ? -1 : index; // Toggle expanded state
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(
                    width: .5,
                    color: required > 0
                        ? Colors.red
                        : miss >= 1
                            ? Colors.lightGreen
                            : Colors.amber),
                borderRadius: BorderRadius.circular(20),
                color: required > 0
                    ? Colors.red.withOpacity(.075)
                    : miss >= 1
                        ? Colors.lightGreen.withOpacity(.075)
                        : Colors.amber.withOpacity(.075),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: percentage / 100),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          settingsProvider.showCircularIndicator && total != 0
                              ? SizedBox(
                                  width: mq.width * .14,
                                  height: mq.width * .14,
                                  child: CircularProgressIndicator(
                                    value: (value.isNaN || value.isInfinite)
                                        ? 0.0
                                        : value.clamp(0.0, 1.0),
                                    strokeWidth: 7,
                                    strokeCap: StrokeCap.round,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    backgroundColor: settingsProvider
                                        .selectedColorPair['absent'],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      settingsProvider
                                          .selectedColorPair['present']!,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: mq.width * .14,
                                  height: mq.width * .14,
                                  child: CircularProgressIndicator(
                                    value: 1,
                                    strokeWidth: .5,
                                    color: required > 0
                                        ? Colors.red
                                        : miss >= 1
                                            ? Colors.lightGreen
                                            : Colors.amber,
                                  ),
                                ),
                          total == 0
                              ? CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  radius: 25,
                                  backgroundImage:
                                      const AssetImage('assets/images/owl.png'),
                                )
                              : CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  child: FittedBox(
                                    child: Text(
                                      '${percentage.floor().toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(attendances[index].subject,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: () => AdManager().navigateWithAd(context,
                              NotesScreen(attendance: attendances[index])),
                          tooltip: 'Sticky Notes',
                          icon: Image.asset(
                            'assets/images/sticky-notes.png',
                            width: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () => AdManager().navigateWithAd(
                              context,
                              AddAttendanceScreen(
                                  attendance: attendances[index])),
                          tooltip: 'Edit',
                          icon: const Icon(
                            CupertinoIcons.pencil_ellipsis_rectangle,
                            size: 25,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: mq.height * .005),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _customContainer(
                                title:
                                    'Attended: ${attendances[index].present}',
                                key: 'present',
                              ),
                              _customContainer(
                                title: 'Missed: ${attendances[index].absent}',
                                key: 'absent',
                              ),
                              _customContainer(
                                title:
                                    'Req.: ${attendances[index].requirement} %',
                                key: 'required',
                              ),
                            ],
                          ),
                          if (total != 0 &&
                              !settingsProvider.showCircularIndicator)
                            Padding(
                              padding: EdgeInsets.only(top: mq.height * .005),
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: 0, end: percentage / 100),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, double value, child) =>
                                    ChartBar(value),
                              ),
                            ),
                          if (required > 0)
                            Padding(
                              padding: EdgeInsets.only(top: mq.height * .005),
                              child: Text(
                                required <= 1
                                    ? 'Attend 1 class'
                                    : attendances[index].requirement == 100
                                        ? "Can't miss any class"
                                        : 'Attend ${required.ceil()} classes in a row',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (miss >= 1)
                            Padding(
                              padding: EdgeInsets.only(top: mq.height * .005),
                              child: Text(
                                miss >= 2
                                    ? 'Can miss ${miss.floor()} classes in a row'
                                    : 'Can miss 1 class',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.green
                                      : Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.only(top: mq.height * .005),
                              child: Text(
                                "Can't miss any class",
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isExpanded)
                            RichText(
                              text: TextSpan(
                                text: 'Last updated: ',
                                style: const TextStyle(
                                    letterSpacing: .25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                                children: [
                                  TextSpan(
                                    text: '$time, $date',
                                    style: TextStyle(
                                        letterSpacing: .75,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _customButton(
                          'Attended',
                          '${attendances[index].present}',
                          () {
                            setState(() {
                              if (attendances[index].present != 0) {
                                attendances[index].present--;
                                attendances[index].time =
                                    DateTime.now().toString();
                              }
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                          () {
                            setState(() {
                              attendances[index].present++;
                              attendances[index].time =
                                  DateTime.now().toString();
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                        ),
                        _customButton(
                          'Missed',
                          '${attendances[index].absent}',
                          () {
                            setState(() {
                              if (attendances[index].absent != 0) {
                                attendances[index].absent--;
                                attendances[index].time =
                                    DateTime.now().toString();
                              }
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                          () {
                            setState(() {
                              attendances[index].absent++;
                              attendances[index].time =
                                  DateTime.now().toString();
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                        ),
                        _customButton(
                          'Required',
                          '${attendances[index].requirement} %',
                          () {
                            setState(() {
                              if (attendances[index].requirement != 0) {
                                attendances[index].requirement -= 5;
                                attendances[index].time =
                                    DateTime.now().toString();
                              }
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                          () {
                            setState(() {
                              if (attendances[index].requirement < 100) {
                                attendances[index].requirement += 5;
                                attendances[index].time =
                                    DateTime.now().toString();
                              }
                            });
                            attendances[index].save();
                            NotificationService.setNotificationsForAttendance(
                                attendances[index]);
                          },
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
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

  Widget _customContainer({required String title, required String key}) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(5)),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: key == 'required'
                  ? Colors.blueGrey
                  : settingsProvider.selectedColorPair[key])),
    );
  }
}
