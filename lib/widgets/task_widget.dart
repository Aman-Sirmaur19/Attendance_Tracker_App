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
    return Card(
      color: widget.task.isCompleted ? Colors.blue.shade100 : null,
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => AddTaskScreen(task: widget.task))),
        leading: IconButton(
          icon: widget.task.isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.circle_outlined),
          onPressed: () => setState(() {
            widget.task.isCompleted = !widget.task.isCompleted;
            widget.task.save();
          }),
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
                      : Colors.black45,
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
                      color:
                          widget.task.isCompleted ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.task.createdAtTime,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          widget.task.isCompleted ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
