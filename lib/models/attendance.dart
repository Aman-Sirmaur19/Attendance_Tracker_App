import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'attendance.g.dart';

@HiveType(typeId: 0)
class Attendance extends HiveObject {
  final String id;
  String time;
  String subject;
  int present;
  int absent;
  int requirement;
  String createdAt;

  Attendance({
    @HiveField(0) required this.id,
    @HiveField(1) required this.time,
    @HiveField(2) required this.subject,
    @HiveField(3) required this.present,
    @HiveField(4) required this.absent,
    @HiveField(5) required this.requirement,
    @HiveField(6) required this.createdAt,
  });

  // create new attendance
  factory Attendance.create({
    required String subject,
    String? time,
    int? present,
    int? absent,
    int? requirement,
    String? createdAt,
  }) =>
      Attendance(
        id: const Uuid().v1(),
        time: time ?? DateTime.now().toString(),
        subject: subject,
        present: present ?? 0,
        absent: absent ?? 0,
        requirement: requirement ?? 75,
        createdAt: createdAt ?? DateTime.now().toString(),
      );
}
