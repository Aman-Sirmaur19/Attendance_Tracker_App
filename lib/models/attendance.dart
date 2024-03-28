class Attendance {
  final String id;
  DateTime time;
  late final String subject;
  int present;
  int absent;
  int requirement;

  Attendance(
    this.id,
    this.time,
    this.subject,
    this.present,
    this.absent,
    this.requirement,
  );
}
