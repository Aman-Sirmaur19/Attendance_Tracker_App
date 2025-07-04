import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/dialogs.dart';
import '../../models/attendance.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../services/notification_service.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key, required this.attendance});

  final Attendance? attendance;

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  bool _isDropdownOpen = false;
  final TextEditingController _subjectController = TextEditingController();
  int _attended = 0;
  int _missed = 0;
  int _required = 75;
  bool _isLab = false;
  late Map<String, String?> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = {
      'Monday': null,
      'Tuesday': null,
      'Wednesday': null,
      'Thursday': null,
      'Friday': null,
      'Saturday': null,
    };
    if (widget.attendance != null) {
      _subjectController.text = widget.attendance!.subject;
      _attended = widget.attendance!.present;
      _missed = widget.attendance!.absent;
      _required = widget.attendance!.requirement;
      _schedules = widget.attendance!.schedules;
      _isLab = widget.attendance!.isLab!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
  }

  // if any attendance already exist return true, else false
  bool _isAttendanceAlreadyExist() {
    if (widget.attendance != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating & editing attendance
  dynamic _createAndEdit() async {
    // update current attendance
    if (_subjectController.text.trim().isNotEmpty &&
        widget.attendance != null) {
      try {
        widget.attendance?.subject = _subjectController.text.trim();
        widget.attendance?.present = _attended;
        widget.attendance?.absent = _missed;
        widget.attendance?.requirement = _required;
        widget.attendance?.schedules = _schedules;
        widget.attendance?.isLab = _isLab;
        widget.attendance?.save();
        await NotificationService.setNotificationsForAttendance(
            widget.attendance!);
        Dialogs.showSnackBar(context, 'Attendance updated successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else if (_subjectController.text.trim().isNotEmpty) {
      var attendance = Attendance.create(
        subject: _subjectController.text.trim(),
        present: _attended,
        absent: _missed,
        requirement: _required,
        createdAt: DateTime.now().toString(),
        schedules: _schedules,
        notes: [],
        isLab: _isLab,
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
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_isAttendanceAlreadyExist()
              ? 'Update Attendance'
              : 'Add Attendance'),
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Once saved, swipe the card (Left <-- Right) to 'DELETE'",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(text: 'Enter subject'),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _subjectController,
              hintText: 'Subject',
              onFieldSubmitted: (value) {
                _subjectController.text = value;
              },
            ),
            const SizedBox(height: 20),
            const CustomText(text: 'Is this a Lab subject?'),
            const SizedBox(height: 4),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: const TextSpan(
                    text: 'Lab subject\n',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Fredoka',
                      color: Colors.lightGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Turn on if this is a Lab subject',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: .75,
                          color: Colors.grey,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  )),
                  Switch(
                    value: _isLab,
                    activeColor: Colors.lightGreen,
                    onChanged: (value) {
                      setState(() {
                        _isLab = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const CustomText(text: 'Enter the no. of classes attended'),
            const SizedBox(height: 5),
            _customCounterContainer(title: 'Attended', number: _attended),
            const SizedBox(height: 20),
            const CustomText(text: 'Enter the no. of classes missed'),
            const SizedBox(height: 5),
            _customCounterContainer(title: 'Missed', number: _missed),
            const SizedBox(height: 20),
            const CustomText(text: 'Enter the % of classes required'),
            const SizedBox(height: 5),
            _customCounterContainer(title: 'Required', number: _required),
            const SizedBox(height: 20),
            const CustomText(
                text: 'Set weekly schedules for push notifications 🔔'),
            const SizedBox(height: 5),
            _customColumn(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (_isAttendanceAlreadyExist())
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
                                            child: const Text(
                                              'Yes',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              widget.attendance?.delete();
                                              Dialogs.showSnackBar(context,
                                                  'Attendance deleted successfully!');
                                              Navigator.of(ctx).pop(true);
                                              Navigator.pop(context);
                                            }),
                                        TextButton(
                                            child: Text(
                                              'No',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                            ),
                                            onPressed: () {
                                              Navigator.of(ctx).pop(false);
                                            }),
                                      ])
                                ],
                              )),
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(CupertinoIcons.delete),
                      label: const Text('Delete')),
                ElevatedButton.icon(
                  onPressed: () => _createAndEdit(),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(_isAttendanceAlreadyExist()
                      ? CupertinoIcons.refresh_thick
                      : CupertinoIcons.list_bullet_indent),
                  label: Text(_isAttendanceAlreadyExist() ? 'Update' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customCounterContainer({required String title, required int number}) {
    return Container(
      height: 50,
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
                    if (title == 'Attended' && _attended != 0) {
                      _attended--;
                    } else if (title == 'Missed' && _missed != 0) {
                      _missed--;
                    } else if ((title == 'Required' && _required != 0)) {
                      _required -= 5;
                    }
                  });
                },
                tooltip: 'Remove',
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Container(
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    title == 'Attended'
                        ? '$_attended'
                        : title == 'Missed'
                            ? '$_missed'
                            : '$_required %',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (title == 'Attended') {
                      _attended++;
                    } else if (title == 'Missed') {
                      _missed++;
                    } else if (title == 'Required' && _required < 100) {
                      _required += 5;
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
                Icon(Icons.alarm_rounded, color: Colors.amber.shade400),
                const SizedBox(width: 12),
                Text(
                  'Routine',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade400,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.amber.shade400,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen)
          ..._schedules.keys.map((day) {
            return ListTile(
              title: Text(
                day,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: _schedules[day] != null
                  ? Text(
                      _schedules[day]!,
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
                    _schedules[day] = localTime.format(context);
                  }
                });
              },
            );
          }).toList(),
      ],
    );
  }
}
