import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/attendance.dart';
import '../widgets/attendance_list.dart';
import '../widgets/new_attendance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Attendance> _userAttendances = [];

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewAttendance(context),
        tooltip: 'Add subject',
        child: const Icon(Icons.add),
      ),
      body:
          AttendanceList(_userAttendances, _deleteAttendance, _editAttendance),
    );
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
