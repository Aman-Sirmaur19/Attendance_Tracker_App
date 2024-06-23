class Attendance {
  final String id;
  String time;
  String subject;
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

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        json['id'],
        json['time'],
        json['subject'],
        json['present'],
        json['absent'],
        json['requirement'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'subject': subject,
        'present': present,
        'absent': absent,
        'requirement': requirement,
      };
}
