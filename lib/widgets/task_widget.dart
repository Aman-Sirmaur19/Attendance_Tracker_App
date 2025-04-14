import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../screens/task/add_task_screen.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context,
          CupertinoPageRoute(builder: (_) => AddTaskScreen(task: widget.task))),
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      leading: IconButton(
        onPressed: () => setState(() {
          widget.task.isCompleted = !widget.task.isCompleted;
          widget.task.save();
        }),
        tooltip: widget.task.isCompleted ? 'Deselect' : 'Select',
        icon: widget.task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.circle_outlined),
      ),
      title: Text(
        widget.task.title,
        style: TextStyle(
            color: widget.task.isCompleted ? Colors.blue : null,
            fontSize: 15,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            decoration:
                widget.task.isCompleted ? TextDecoration.lineThrough : null),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.subTitle,
            style: TextStyle(
                fontSize: 15,
                color: widget.task.isCompleted
                    ? Colors.blue.shade300
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                decoration: widget.task.isCompleted
                    ? TextDecoration.lineThrough
                    : null),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat.yMMMEd().format(widget.task.createdAtDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.task.isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.task.createdAtTime,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.task.isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
