import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../main.dart';
import '../../models/attendance.dart';
import '../../services/notification_service.dart';
import '../../widgets/dialogs.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key, required this.attendance});

  final Attendance? attendance;

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  bool _isDropdownOpen = false;
  final TextEditingController subjectController = TextEditingController();
  int attended = 0;
  int missed = 0;
  int required = 75;
  late Map<String, String?> schedules;

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
    schedules = {
      'Monday': null,
      'Tuesday': null,
      'Wednesday': null,
      'Thursday': null,
      'Friday': null,
      'Saturday': null,
    };
    if (widget.attendance != null) {
      subjectController.text = widget.attendance!.subject;
      attended = widget.attendance!.present;
      missed = widget.attendance!.absent;
      required = widget.attendance!.requirement;
      schedules = widget.attendance!.schedules;
    }
  }

  @override
  void dispose() {
    super.dispose();
    subjectController.dispose();
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

  // if any attendance already exist return true, else false
  bool isAttendanceAlreadyExist() {
    if (widget.attendance != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating or updating attendance
  dynamic isAttendanceAlreadyExistUpdateElseCreate() async {
    // update current attendance
    if (subjectController.text.trim().isNotEmpty && widget.attendance != null) {
      try {
        widget.attendance?.subject = subjectController.text.trim();
        widget.attendance?.present = attended;
        widget.attendance?.absent = missed;
        widget.attendance?.requirement = required;
        widget.attendance?.schedules = schedules;
        widget.attendance?.save();
        await NotificationService.setNotificationsForAttendance(
            widget.attendance!);
        Dialogs.showSnackBar(context, 'Attendance updated successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else if (subjectController.text.trim().isNotEmpty) {
      var attendance = Attendance.create(
        subject: subjectController.text.trim(),
        present: attended,
        absent: missed,
        requirement: required,
        createdAt: DateTime.now().toString(),
        schedules: schedules,
      );
      // We are adding this new attendance to Hive DB using inherited widget
      BaseWidget.of(context).dataStore.addAttendance(attendance: attendance);
      // Schedule notifications
      await NotificationService.setNotificationsForAttendance(attendance);
      Dialogs.showSnackBar(context, 'Attendance created successfully!');
      Navigator.pop(context);
    } else {
      Dialogs.showErrorSnackBar(context, 'Enter subject');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            isAttendanceAlreadyExist() ? 'Update Attendance' : 'Add Attendance',
            style: const TextStyle(
              letterSpacing: 2,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottomNavigationBar: isBannerLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
            : const SizedBox(),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: ListView(
            children: [
              const Text(
                'Enter subject',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: subjectController,
                hintText: 'Subject',
                onFieldSubmitted: (value) {
                  subjectController.text = value;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Enter the no. of classes attended',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              _customCounterContainer(title: 'Attended', number: attended),
              const SizedBox(height: 25),
              const Text(
                'Enter the no. of classes missed',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              _customCounterContainer(title: 'Missed', number: missed),
              const SizedBox(height: 25),
              const Text(
                'Enter the % of classes required',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              _customCounterContainer(title: 'Required', number: required),
              const SizedBox(height: 25),
              const Text(
                'Set weekly schedules for push notifications',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              _customColumn(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (isAttendanceAlreadyExist())
                    ElevatedButton.icon(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content:
                                      const Text('Do you want to delete this?'),
                                  actions: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                widget.attendance?.delete();
                                                Dialogs.showSnackBar(context,
                                                    'Attendance deleted successfully!');
                                                Navigator.of(ctx).pop(true);
                                                Navigator.pop(context);
                                              }),
                                          TextButton(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                              }),
                                        ])
                                  ],
                                )),
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red),
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        icon: const Icon(CupertinoIcons.delete),
                        label: const Text('Delete')),
                  ElevatedButton.icon(
                    onPressed: () => isAttendanceAlreadyExistUpdateElseCreate(),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue),
                    icon: Icon(isAttendanceAlreadyExist()
                        ? CupertinoIcons.refresh_thick
                        : CupertinoIcons.list_bullet_indent),
                    label: Text(isAttendanceAlreadyExist() ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customCounterContainer({required String title, required int number}) {
    return Container(
      // width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                title == 'Attended'
                    ? Icon(CupertinoIcons.check_mark_circled,
                        color: Colors.blue.shade300)
                    : title == 'Missed'
                        ? Icon(CupertinoIcons.clear_circled,
                            color: Colors.red.shade300)
                        : Icon(Icons.assignment_outlined,
                            color: Colors.blueGrey.shade300),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: title == 'Attended'
                          ? Colors.blue.shade300
                          : title == 'Missed'
                              ? Colors.red.shade300
                              : Colors.blueGrey.shade300,
                    )),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (title == 'Attended' && attended != 0) {
                      attended--;
                    } else if (title == 'Missed' && missed != 0) {
                      missed--;
                    } else if ((title == 'Required' && required != 0)) {
                      required -= 5;
                    }
                  });
                },
                tooltip: 'Remove',
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Container(
                // margin: const EdgeInsets.only(right: 10),
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    title == 'Attended'
                        ? '$attended'
                        : title == 'Missed'
                            ? '$missed'
                            : '$required %',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (title == 'Attended') {
                      attended++;
                    } else if (title == 'Missed') {
                      missed++;
                    } else if (title == 'Required' && required < 100) {
                      required += 5;
                    }
                  });
                },
                tooltip: 'Add',
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            // width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(Icons.alarm_rounded, color: Colors.amber.shade300),
                const SizedBox(width: 12),
                Text(
                  'Routine',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade300,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.amber.shade300,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen)
          ...schedules.keys.map((day) {
            return ListTile(
              title: Text(
                day,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              trailing: schedules[day] != null
                  ? Text(
                      schedules[day]!,
                      style: const TextStyle(color: Colors.blue, fontSize: 15),
                    )
                  : const Text(
                      'Set Time',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
              onTap: () async {
                final localTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() {
                  if (localTime != null) {
                    schedules[day] = localTime.format(context);
                  }
                });
              },
            );
          }).toList(),
      ],
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final Function(String)? onFieldSubmitted;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: Colors.blue,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        prefixIcon:
            const Icon(Icons.stacked_bar_chart_rounded, color: Colors.grey),
        hintText: hintText,
        hintStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
