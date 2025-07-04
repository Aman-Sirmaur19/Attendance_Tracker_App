import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../utils/dialogs.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_text_form_field.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, required this.task});

  final Task? task;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _time;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.subTitle;
    }
    _time =
        widget.task?.createdAtTime ?? DateFormat.jm().format(DateTime.now());
    _date = widget.task?.createdAtDate ?? DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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
    if (_titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        widget.task != null) {
      try {
        widget.task?.title = _titleController.text.trim();
        widget.task?.subTitle = _descriptionController.text.trim();
        widget.task?.createdAtTime = _time!;
        widget.task?.createdAtDate = _date!;
        widget.task?.save();
        Dialogs.showSnackBar(context, 'Task updated successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else if (_titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty) {
      var task = Task.create(
        title: _titleController.text.trim(),
        subTitle: _descriptionController.text.trim(),
        createdAtTime: _time,
        createdAtDate: _date,
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
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Once saved, swipe the card (Left <-- Right) to 'DELETE'",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(text: 'What\'s your plan?'),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _titleController,
              hintText: 'Plan',
              onFieldSubmitted: (value) {
                _titleController.text = value;
              },
            ),
            const SizedBox(height: 20),
            const CustomText(text: 'Provide a brief description'),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _descriptionController,
              hintText: 'Add note',
              onFieldSubmitted: (value) {
                _descriptionController.text = value;
              },
            ),
            const SizedBox(height: 20),
            const CustomText(text: 'Set time for the task'),
            const SizedBox(height: 5),
            _customDateTimePickerContainer('Time', CupertinoIcons.time),
            const SizedBox(height: 20),
            const CustomText(text: 'Set date for the task'),
            const SizedBox(height: 5),
            _customDateTimePickerContainer('Date', CupertinoIcons.calendar),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (_isTaskAlreadyExist())
                  ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text('Do you want to delete this?'),
                            actions: <Widget>[
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          _deleteTask();
                                          Dialogs.showSnackBar(context,
                                              'Task deleted successfully!');
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }),
                                    TextButton(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        }),
                                  ])
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(CupertinoIcons.delete),
                      label: const Text('Delete')),
                ElevatedButton.icon(
                  onPressed: () => _isTaskAlreadyExistUpdateElseCreate(),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
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
    );
  }

  Widget _customDateTimePickerContainer(String dateTime, IconData icon) {
    return InkWell(
      onTap: () async {
        if (dateTime == 'Time') {
          final localTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          setState(() {
            if (localTime != null) _time = localTime.format(context);
          });
        } else {
          final localDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(3000));
          setState(() {
            if (localDate != null) _date = localDate;
          });
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
          borderRadius: BorderRadius.circular(10),
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
                          ? _time!
                          : DateFormat.yMMMEd().format(_date!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                      )),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 80,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
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
