import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'routine.g.dart';

@HiveType(typeId: 2)
class Routine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String day; // e.g. Mon, Tue, Wed

  @HiveField(2)
  String timeSlot; // e.g. 9 AM, 10 AM

  @HiveField(3)
  String subject;

  Routine({
    required this.id,
    required this.day,
    required this.timeSlot,
    required this.subject,
  });

  // Factory for creating a new routine entry
  factory Routine.create({
    required String day,
    required String timeSlot,
    required String subject,
  }) =>
      Routine(
        id: const Uuid().v1(),
        day: day,
        timeSlot: timeSlot,
        subject: subject,
      );
}
