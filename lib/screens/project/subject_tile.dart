import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/dialogs.dart';
import '../../models/project.dart';
import '../../widgets/add_button.dart';
import 'tree_group.dart';

class SubjectTile extends StatefulWidget {
  final ProjectSubject subject;
  final Project parentProject;
  final Color color;

  const SubjectTile({
    super.key,
    required this.subject,
    required this.color,
    required this.parentProject,
  });

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  bool _expanded = false;

  double get _progress {
    if (widget.subject.chapters.isEmpty) {
      return widget.subject.isCompleted ? 1.0 : 0.0;
    }
    int completed = widget.subject.chapters.where((c) => c.isCompleted).length;
    return completed / widget.subject.chapters.length;
  }

  void _save() {
    // Saving the parent project ensures the whole structure updates in Hive
    widget.parentProject.save();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final chapterCount = widget.subject.chapters.length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12, right: 8),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: (value.isNaN || value.isInfinite)
                          ? 0.0
                          : value.clamp(0.0, 1.0),
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: widget.color.withOpacity(.3),
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    ),
                  ),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
            ),
            title: Text(
              widget.subject.title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text('Chapters: $chapterCount',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      bool newVal = !widget.subject.isCompleted;
                      widget.subject.isCompleted = newVal;
                      widget.subject.toggle(newVal); // Cascade
                      _save();
                    });
                  },
                  child: Icon(
                    widget.subject.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.check_mark_circled,
                    color: widget.color,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Dialogs.showAddEditDialog(context,
                          title: 'Edit Subject',
                          initialText: widget.subject.title, onSave: (val) {
                        setState(() {
                          widget.subject.title = val;
                          _save();
                        });
                      });
                    } else if (value == 'delete') {
                      Dialogs.confirmDelete(context, () {
                        setState(() {
                          widget.parentProject.subjects.remove(widget.subject);
                          _save();
                        });
                      }, widget.subject.title);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _expanded ? 0.5 : 0.0,
                  child: const Icon(CupertinoIcons.chevron_down,
                      size: 15, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TreeGroup(
              children: [
                ...widget.subject.chapters.map((chapter) => _ChapterTile(
                      chapter: chapter,
                      rootSubject: widget.subject,
                      saveCallback: _save, // Pass save logic down
                      color: widget.color,
                    )),
                AddButton(
                  label: 'Add New Chapter',
                  color: widget.color,
                  onPressed: () => Dialogs.showAddEditDialog(
                    context,
                    title: 'Add Chapter to ${widget.subject.title}',
                    onSave: (val) {
                      setState(() {
                        widget.subject.chapters
                            .add(ProjectChapter.create(title: val));
                        widget.subject.isCompleted = false;
                        _save();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}

class _ChapterTile extends StatefulWidget {
  final ProjectChapter chapter;
  final ProjectSubject rootSubject;
  final VoidCallback saveCallback;
  final Color color;

  const _ChapterTile(
      {required this.chapter,
      required this.rootSubject,
      required this.saveCallback,
      required this.color});

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile> {
  bool _expanded = false;

  double get _progress {
    if (widget.chapter.topics.isEmpty) {
      return widget.chapter.isCompleted ? 1.0 : 0.0;
    }
    int completed = widget.chapter.topics.where((t) => t.isCompleted).length;
    return completed / widget.chapter.topics.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12, right: 8),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              widget.chapter.title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Topics: ${widget.chapter.topics.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  color: widget.color,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      bool newVal = !widget.chapter.isCompleted;
                      widget.chapter.isCompleted = newVal;
                      widget.chapter.toggle(newVal); // Cascade down

                      // Bubble up logic
                      if (newVal) {
                        if (widget.rootSubject.chapters
                            .every((c) => c.isCompleted)) {
                          widget.rootSubject.isCompleted = true;
                        }
                      } else {
                        widget.rootSubject.isCompleted = false;
                      }
                      widget.saveCallback();
                    });
                  },
                  child: Icon(
                    widget.chapter.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.check_mark_circled,
                    size: 20,
                    color: widget.color,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Dialogs.showAddEditDialog(context,
                          title: 'Edit Chapter',
                          initialText: widget.chapter.title, onSave: (val) {
                        setState(() {
                          widget.chapter.title = val;
                          widget.saveCallback();
                        });
                      });
                    } else if (value == 'delete') {
                      Dialogs.confirmDelete(context, () {
                        setState(() {
                          widget.rootSubject.chapters.remove(widget.chapter);
                          widget.saveCallback();
                        });
                      }, widget.chapter.title);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(CupertinoIcons.chevron_down,
                      size: 15, color: Colors.grey),
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TreeGroup(
              children: [
                ...widget.chapter.topics.map((topic) => _TopicTile(
                    topic: topic,
                    chapter: widget.chapter,
                    rootSubject: widget.rootSubject,
                    saveCallback: widget.saveCallback,
                    color: widget.color)),
                AddButton(
                  label: 'Add New Topic',
                  onPressed: () => Dialogs.showAddEditDialog(context,
                      title: 'Add Topic', onSave: (val) {
                    setState(() {
                      widget.chapter.topics
                          .add(ProjectTopic.create(title: val));
                      widget.chapter.isCompleted = false;
                      widget.rootSubject.isCompleted = false;
                      widget.saveCallback();
                    });
                  }),
                  color: widget.color,
                ),
              ],
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}

class _TopicTile extends StatefulWidget {
  final ProjectTopic topic;
  final ProjectChapter chapter;
  final ProjectSubject rootSubject;
  final VoidCallback saveCallback;
  final Color color;

  const _TopicTile(
      {required this.topic,
      required this.chapter,
      required this.rootSubject,
      required this.saveCallback,
      required this.color});

  @override
  State<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<_TopicTile> {
  bool _expanded = false;

  double get _progress {
    if (widget.topic.subTopics.isEmpty) {
      return widget.topic.isCompleted ? 1.0 : 0.0;
    }
    int completed = widget.topic.subTopics.where((s) => s.isCompleted).length;
    return completed / widget.topic.subTopics.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              widget.topic.title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              minHeight: 5,
              color: widget.color,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      bool newVal = !widget.topic.isCompleted;
                      widget.topic.toggle(newVal); // Cascade

                      // Bubble up
                      if (newVal) {
                        if (widget.chapter.topics.every((t) => t.isCompleted)) {
                          widget.chapter.isCompleted = true;
                          if (widget.rootSubject.chapters
                              .every((c) => c.isCompleted)) {
                            widget.rootSubject.isCompleted = true;
                          }
                        }
                      } else {
                        widget.chapter.isCompleted = false;
                        widget.rootSubject.isCompleted = false;
                      }
                      widget.saveCallback();
                    });
                  },
                  child: Icon(
                    widget.topic.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.check_mark_circled,
                    size: 20,
                    color: widget.color,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Dialogs.showAddEditDialog(context,
                          title: 'Edit Topic',
                          initialText: widget.topic.title, onSave: (val) {
                        setState(() {
                          widget.topic.title = val;
                          widget.saveCallback();
                        });
                      });
                    } else if (value == 'delete') {
                      Dialogs.confirmDelete(context, () {
                        setState(() {
                          widget.chapter.topics.remove(widget.topic);
                          widget.saveCallback();
                        });
                      }, widget.topic.title);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(CupertinoIcons.chevron_down,
                      size: 15, color: Colors.grey.withOpacity(0.5)),
                ),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TreeGroup(
              children: [
                ...widget.topic.subTopics.map((sub) => _SubTopicTile(
                      subTopic: sub,
                      parentTopic: widget.topic,
                      parentChapter: widget.chapter,
                      rootSubject: widget.rootSubject,
                      saveCallback: widget.saveCallback,
                      color: widget.color,
                      onDelete: () {
                        setState(() {
                          widget.topic.subTopics.remove(sub);
                          widget.saveCallback();
                        });
                      },
                    )),
                AddButton(
                  label: 'Add Sub-Topic',
                  onPressed: () => Dialogs.showAddEditDialog(context,
                      title: 'Add Sub-Topic', onSave: (val) {
                    setState(() {
                      widget.topic.subTopics
                          .add(ProjectSubTopic.create(title: val));
                      widget.topic.isCompleted = false;
                      widget.chapter.isCompleted = false;
                      widget.rootSubject.isCompleted = false;
                      widget.saveCallback();
                    });
                  }),
                  color: widget.color,
                ),
              ],
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}

class _SubTopicTile extends StatelessWidget {
  final ProjectSubTopic subTopic;
  final ProjectTopic parentTopic;
  final ProjectChapter parentChapter;
  final ProjectSubject rootSubject;
  final VoidCallback saveCallback;
  final Color color;
  final VoidCallback onDelete;

  const _SubTopicTile({
    required this.subTopic,
    required this.parentTopic,
    required this.parentChapter,
    required this.rootSubject,
    required this.saveCallback,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        dense: true,
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: const Icon(Icons.circle, size: 8, color: Colors.grey),
        title: Text(
          subTopic.title,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            color: subTopic.isCompleted ? Colors.grey : null,
            decoration:
                subTopic.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                bool newVal = !subTopic.isCompleted;
                subTopic.isCompleted = newVal;

                // Bubble Up Logic
                if (!newVal) {
                  parentTopic.isCompleted = false;
                  parentChapter.isCompleted = false;
                  rootSubject.isCompleted = false;
                } else {
                  if (parentTopic.subTopics.every((s) => s.isCompleted)) {
                    parentTopic.isCompleted = true;
                    if (parentChapter.topics.every((t) => t.isCompleted)) {
                      parentChapter.isCompleted = true;
                      if (rootSubject.chapters.every((c) => c.isCompleted)) {
                        rootSubject.isCompleted = true;
                      }
                    }
                  }
                }
                saveCallback();
              },
              child: Icon(
                subTopic.isCompleted
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.check_mark_circled,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => Dialogs.showAddEditDialog(context,
                  title: 'Edit Sub-Topic',
                  initialText: subTopic.title, onSave: (val) {
                subTopic.title = val;
                saveCallback();
              }),
              child:
                  const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () =>
                  Dialogs.confirmDelete(context, onDelete, subTopic.title),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
