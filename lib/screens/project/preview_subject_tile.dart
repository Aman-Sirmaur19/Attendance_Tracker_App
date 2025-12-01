import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/project.dart';
import 'tree_group.dart';

class PreviewSubjectTile extends StatefulWidget {
  final ProjectSubject subject;
  final Color color;

  const PreviewSubjectTile(
      {super.key, required this.subject, required this.color});

  @override
  State<PreviewSubjectTile> createState() => _PreviewSubjectTileState();
}

class _PreviewSubjectTileState extends State<PreviewSubjectTile> {
  bool _expanded = false;

  double get _progress {
    if (widget.subject.chapters.isEmpty) {
      return widget.subject.isCompleted ? 1.0 : 0.0;
    }
    int completed = widget.subject.chapters.where((c) => c.isCompleted).length;
    return completed / widget.subject.chapters.length;
  }

  void _rebuild() {
    setState(() {}); // Just rebuild to show checkmark toggle
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
            tileColor: Theme.of(context).colorScheme.surface,
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
                    });
                  },
                  child: Icon(
                    widget.subject.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.check_mark_circled,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 8),
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
                ...widget.subject.chapters.map((chapter) => _PreviewChapterTile(
                      chapter: chapter,
                      rootSubject: widget.subject,
                      rebuildCallback: _rebuild,
                      color: widget.color,
                    )),
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

class _PreviewChapterTile extends StatefulWidget {
  final ProjectChapter chapter;
  final ProjectSubject rootSubject;
  final VoidCallback rebuildCallback;
  final Color color;

  const _PreviewChapterTile(
      {required this.chapter,
      required this.rootSubject,
      required this.rebuildCallback,
      required this.color});

  @override
  State<_PreviewChapterTile> createState() => _PreviewChapterTileState();
}

class _PreviewChapterTileState extends State<_PreviewChapterTile> {
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
            tileColor: Theme.of(context).colorScheme.surface,
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                      widget.chapter.toggle(newVal); // Cascade

                      if (newVal) {
                        if (widget.rootSubject.chapters
                            .every((c) => c.isCompleted)) {
                          widget.rootSubject.isCompleted = true;
                        }
                      } else {
                        widget.rootSubject.isCompleted = false;
                      }
                      widget.rebuildCallback();
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
                const SizedBox(width: 8),
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
                ...widget.chapter.topics.map((topic) => _PreviewTopicTile(
                    topic: topic,
                    chapter: widget.chapter,
                    rootSubject: widget.rootSubject,
                    rebuildCallback: widget.rebuildCallback,
                    color: widget.color)),
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

class _PreviewTopicTile extends StatefulWidget {
  final ProjectTopic topic;
  final ProjectChapter chapter;
  final ProjectSubject rootSubject;
  final VoidCallback rebuildCallback;
  final Color color;

  const _PreviewTopicTile(
      {required this.topic,
      required this.chapter,
      required this.rootSubject,
      required this.rebuildCallback,
      required this.color});

  @override
  State<_PreviewTopicTile> createState() => _PreviewTopicTileState();
}

class _PreviewTopicTileState extends State<_PreviewTopicTile> {
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
            tileColor: Theme.of(context).colorScheme.surface,
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sub-Topics: ${widget.topic.subTopics.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  color: widget.color,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      bool newVal = !widget.topic.isCompleted;
                      widget.topic.toggle(newVal);

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
                      widget.rebuildCallback();
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
                const SizedBox(width: 8),
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
                ...widget.topic.subTopics.map((sub) => _PreviewSubTopicTile(
                      subTopic: sub,
                      parentTopic: widget.topic,
                      parentChapter: widget.chapter,
                      rootSubject: widget.rootSubject,
                      rebuildCallback: widget.rebuildCallback,
                      color: widget.color,
                    )),
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

class _PreviewSubTopicTile extends StatelessWidget {
  final ProjectSubTopic subTopic;
  final ProjectTopic parentTopic;
  final ProjectChapter parentChapter;
  final ProjectSubject rootSubject;
  final VoidCallback rebuildCallback;
  final Color color;

  const _PreviewSubTopicTile({
    required this.subTopic,
    required this.parentTopic,
    required this.parentChapter,
    required this.rootSubject,
    required this.rebuildCallback,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        dense: true,
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        tileColor: Theme.of(context).colorScheme.surface,
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
        trailing: InkWell(
          onTap: () {
            bool newVal = !subTopic.isCompleted;
            subTopic.isCompleted = newVal;

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
            rebuildCallback();
          },
          child: Icon(
            subTopic.isCompleted
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.check_mark_circled,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
