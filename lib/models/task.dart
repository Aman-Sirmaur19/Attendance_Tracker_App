import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  final String id;
  String title;
  String subTitle;
  String createdAtTime;
  DateTime createdAtDate;
  bool isCompleted;

  Task({
    @HiveField(0) required this.id,
    @HiveField(1) required this.title,
    @HiveField(2) required this.subTitle,
    @HiveField(3) required this.createdAtTime,
    @HiveField(4) required this.createdAtDate,
    @HiveField(5) required this.isCompleted,
  });

  // create new task
  factory Task.create({
    required String? title,
    required String? subTitle,
    String? createdAtTime,
    DateTime? createdAtDate,
  }) =>
      Task(
        id: const Uuid().v1(),
        title: title ?? '',
        subTitle: subTitle ?? '',
        createdAtTime: createdAtTime ?? DateFormat.jm().format(DateTime.now()),
        createdAtDate: createdAtDate ?? DateTime.now(),
        isCompleted: false,
      );
}
