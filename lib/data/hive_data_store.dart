import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

/// All the [CRUD] operation method for Hive DB
class HiveDataStore {
  // Box name - String
  static const boxName = 'taskBox';

  // Our current box with all the saved data inside - Box<Task>
  final Box<Task> box = Hive.box<Task>(boxName);

  // Add new Task to Box
  Future<void> addTask({required Task task}) async {
    await box.put(task.id, task);
  }

  // Show Task
  Future<Task?> getTask({required String id}) async {
    return box.get(id);
  }

  // Update Task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  // Delete Task
  Future<void> deleteTask({required Task task}) async {
    await task.delete();
  }

  // Listen to Box Changes
  // using this method we will listen to box changes and update the UI accordingly.
  ValueListenable<Box<Task>> listenToTask() => box.listenable();
}
