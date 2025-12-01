import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@HiveType(typeId: 7)
class ProjectSubTopic {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;

  ProjectSubTopic({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory ProjectSubTopic.create({required String title}) => ProjectSubTopic(
    id: const Uuid().v1(),
    title: title,
  );
}

@HiveType(typeId: 6)
class ProjectTopic {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;
  @HiveField(3)
  List<ProjectSubTopic> subTopics;

  ProjectTopic({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.subTopics,
  });

  factory ProjectTopic.create({required String title}) => ProjectTopic(
    id: const Uuid().v1(),
    title: title,
    subTopics: [],
  );

  void toggle(bool value) {
    isCompleted = value;
    for (var sub in subTopics) {
      sub.isCompleted = value;
    }
  }
}

@HiveType(typeId: 5)
class ProjectChapter {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;
  @HiveField(3)
  List<ProjectTopic> topics;

  ProjectChapter({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.topics,
  });

  factory ProjectChapter.create({required String title}) => ProjectChapter(
    id: const Uuid().v1(),
    title: title,
    topics: [],
  );

  void toggle(bool value) {
    isCompleted = value;
    for (var topic in topics) {
      topic.toggle(value);
    }
  }
}

@HiveType(typeId: 4)
class ProjectSubject extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  bool isCompleted;
  @HiveField(3)
  List<ProjectChapter> chapters;

  ProjectSubject({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.chapters,
  });

  factory ProjectSubject.create({required String title}) => ProjectSubject(
    id: const Uuid().v1(),
    title: title,
    chapters: [],
  );

  void toggle(bool value) {
    isCompleted = value;
    for (var chapter in chapters) {
      chapter.toggle(value);
    }
  }
}

@HiveType(typeId: 3)
class Project extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<ProjectSubject> subjects;

  Project({
    required this.id,
    required this.title,
    required this.subjects,
  });

  factory Project.create({required String title}) => Project(
    id: const Uuid().v1(),
    title: title,
    subjects: [],
  );
}