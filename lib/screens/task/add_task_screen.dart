import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/custom_banner_ad.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, required this.task});

  final Task? task;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? time;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.subTitle;
    }
    time = widget.task?.createdAtTime ?? DateFormat.jm().format(DateTime.now());
    date = widget.task?.createdAtDate ?? DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  // if any task already exist return true, else false
  bool _isTaskAlreadyExist() {
    if (widget.task != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating or updating task
  dynamic _isTaskAlreadyExistUpdateElseCreate() {
    // update current task
    if (titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        widget.task != null) {
      try {
        widget.task?.title = titleController.text.trim();
        widget.task?.subTitle = descriptionController.text.trim();
        widget.task?.createdAtTime = time!;
        widget.task?.createdAtDate = date!;
        widget.task?.save();
        Dialogs.showSnackBar(context, 'Task updated successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else if (titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty) {
      var task = Task.create(
        title: titleController.text.trim(),
        subTitle: descriptionController.text.trim(),
        createdAtTime: time,
        createdAtDate: date,
      );
      // We are adding this new task to Hive DB using inherited widget
      BaseWidget.of(context).dataStore.addTask(task: task);
      Dialogs.showSnackBar(context, 'Task created successfully!');
      Navigator.pop(context);
    } else {
      Dialogs.showErrorSnackBar(context, 'Fill all the fields');
    }
  }

  dynamic _deleteTask() {
    return widget.task?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_isTaskAlreadyExist() ? 'Update Task' : 'Add Task'),
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: ListView(
            children: [
              const Text(
                'What\'s your plan?',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: titleController,
                hintText: 'Plan',
                onFieldSubmitted: (value) {
                  titleController.text = value;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Provide a brief description',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: descriptionController,
                hintText: 'Add note',
                isForDescription: true,
                onFieldSubmitted: (value) {
                  descriptionController.text = value;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Set time for the task',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              customDateTimePickerContainer('Time', CupertinoIcons.time),
              const SizedBox(height: 25),
              const Text(
                'Set date for the task',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              customDateTimePickerContainer('Date', CupertinoIcons.calendar),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_isTaskAlreadyExist())
                    ElevatedButton.icon(
                        onPressed: () {
                          _deleteTask();
                          Dialogs.showSnackBar(
                              context, 'Task deleted successfully!');
                          Navigator.pop(context);
                        },
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red),
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        icon: const Icon(CupertinoIcons.delete),
                        label: const Text('Delete')),
                  ElevatedButton.icon(
                    onPressed: () => _isTaskAlreadyExistUpdateElseCreate(),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue),
                    icon: Icon(_isTaskAlreadyExist()
                        ? CupertinoIcons.refresh_thick
                        : CupertinoIcons.list_bullet_indent),
                    label: Text(_isTaskAlreadyExist() ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customDateTimePickerContainer(String dateTime, IconData icon) {
    return InkWell(
      onTap: () async {
        if (dateTime == 'Time') {
          final localTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          setState(() {
            if (localTime != null) time = localTime.format(context);
          });
        } else {
          final localDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(3000));
          setState(() {
            if (localDate != null) date = localDate;
          });
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                      dateTime == 'Time'
                          ? time!
                          : DateFormat.yMMMEd().format(date!),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1,
                          color: Colors.black)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 80,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(dateTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onFieldSubmitted,
    this.isForDescription = false,
  });

  final TextEditingController? controller;
  final Function(String)? onFieldSubmitted;

  final String hintText;
  final bool isForDescription;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: Colors.blue,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        prefixIcon: isForDescription
            ? const Icon(Icons.bookmark_border_rounded, color: Colors.grey)
            : const Icon(Icons.sports_gymnastics_rounded, color: Colors.grey),
        hintText: hintText,
        hintStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
