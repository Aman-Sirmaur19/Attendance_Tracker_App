// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectSubTopicAdapter extends TypeAdapter<ProjectSubTopic> {
  @override
  final int typeId = 7;

  @override
  ProjectSubTopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSubTopic(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSubTopic obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSubTopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectTopicAdapter extends TypeAdapter<ProjectTopic> {
  @override
  final int typeId = 6;

  @override
  ProjectTopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectTopic(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      subTopics: (fields[3] as List).cast<ProjectSubTopic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectTopic obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.subTopics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectTopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectChapterAdapter extends TypeAdapter<ProjectChapter> {
  @override
  final int typeId = 5;

  @override
  ProjectChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectChapter(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      topics: (fields[3] as List).cast<ProjectTopic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectChapter obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.topics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectSubjectAdapter extends TypeAdapter<ProjectSubject> {
  @override
  final int typeId = 4;

  @override
  ProjectSubject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSubject(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      chapters: (fields[3] as List).cast<ProjectChapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSubject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 3;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      title: fields[1] as String,
      subjects: (fields[2] as List).cast<ProjectSubject>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
