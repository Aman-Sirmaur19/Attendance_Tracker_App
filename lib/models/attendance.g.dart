// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceAdapter extends TypeAdapter<Attendance> {
  @override
  final int typeId = 0;

  @override
  Attendance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attendance(
      id: fields[0] as String,
      time: fields[1] as String,
      subject: fields[2] as String,
      present: fields[3] as int,
      absent: fields[4] as int,
      requirement: fields[5] as int,
      createdAt: fields[6] as String,
      schedules: (fields[7] as Map).cast<String, String?>(),
      notes: (fields[8] as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      isLab: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Attendance obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.present)
      ..writeByte(4)
      ..write(obj.absent)
      ..writeByte(5)
      ..write(obj.requirement)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.schedules)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isLab);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
