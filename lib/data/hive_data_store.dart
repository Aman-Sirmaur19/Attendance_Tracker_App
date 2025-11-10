import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/attendance.dart';
import '../models/task.dart';
import '../models/routine.dart';

/// All the [CRUD] operation method for Hive DB
class HiveDataStore {
  // -------------------- TASK --------------------

  static const taskBoxName = 'taskBox';
  final Box<Task> box = Hive.box<Task>(taskBoxName);

  Future<void> addTask({required Task task}) async {
    await box.put(task.id, task);
  }

  Future<Task?> getTask({required String id}) async {
    return box.get(id);
  }

  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  Future<void> deleteTask({required Task task}) async {
    await task.delete();
  }

  ValueListenable<Box<Task>> listenToTask() => box.listenable();

  // -------------------- ATTENDANCE --------------------

  static const attendanceBoxName = 'attendanceBox';
  final Box<Attendance> attendanceBox = Hive.box<Attendance>(attendanceBoxName);

  Future<void> addAttendance({required Attendance attendance}) async {
    await attendanceBox.put(attendance.id, attendance);
  }

  Future<Attendance?> getAttendance({required String id}) async {
    return attendanceBox.get(id);
  }

  Future<void> updateAttendance({required Attendance attendance}) async {
    await attendance.save();
  }

  Future<void> deleteAttendance({required Attendance attendance}) async {
    await attendance.delete();
  }

  ValueListenable<Box<Attendance>> listenToAttendance() =>
      attendanceBox.listenable();

  // -------------------- ROUTINE --------------------

  static const routineBoxName = 'routineBox';
  final Box<Routine> routineBox = Hive.box<Routine>(routineBoxName);

  Future<void> addRoutine({required Routine routine}) async {
    await routineBox.put(routine.id, routine);
  }

  Future<Routine?> getRoutine({required String id}) async {
    return routineBox.get(id);
  }

  Future<void> updateRoutine({required Routine routine}) async {
    await routine.save();
  }

  Future<void> deleteRoutine({required Routine routine}) async {
    await routine.delete();
  }

  /// Find routine entry by day + timeSlot
  Routine? getRoutineByDayAndTime(String day, String timeSlot) {
    try {
      return routineBox.values.firstWhere(
        (r) => r.day == day && r.timeSlot == timeSlot,
      );
    } catch (e) {
      return null;
    }
  }

  /// Reset all routines (clear timetable)
  Future<void> clearAllRoutines() async {
    await routineBox.clear();
  }

  /// Listen for UI updates
  ValueListenable<Box<Routine>> listenToRoutine() => routineBox.listenable();
}
