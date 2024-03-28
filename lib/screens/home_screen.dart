import 'package:flutter/material.dart';

import '../models/attendance.dart';
import '../widgets/attendance_list.dart';
import '../widgets/new_attendance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Attendance> _userAttendances = [];

  void _addNewAttendance(
    String subject,
    int present,
    int absent,
    int requirement,
  ) {
    final newAttendance = Attendance(
      DateTime.now().toString(),
      DateTime.now(),
      subject,
      present,
      absent,
      requirement,
    );

    setState(() {
      _userAttendances.add(newAttendance);
    });
  }

  void _startAddNewAttendance(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (ctx) {
          return NewAttendance(_addNewAttendance);
        });
  }

  void _deleteAttendance(String id) {
    setState(() {
      _userAttendances.removeWhere((attendance) => attendance.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Attendance Tracker',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewAttendance(context),
        tooltip: 'Add subject',
        child: const Icon(Icons.add),
      ),
      body: AttendanceList(_userAttendances, _deleteAttendance),
    );
  }
}
