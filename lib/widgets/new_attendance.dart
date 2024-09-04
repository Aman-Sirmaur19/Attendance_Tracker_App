import 'package:flutter/material.dart';

import 'dialogs.dart';

class NewAttendance extends StatefulWidget {
  final Function addAttendance;

  const NewAttendance(this.addAttendance, {super.key});

  @override
  State<NewAttendance> createState() => _NewAttendanceState();
}

class _NewAttendanceState extends State<NewAttendance> {
  final _subjectController = TextEditingController();
  int attended = 0;
  int missed = 0;
  int required = 75;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
            hintText: 'Eg. Physics',
            hintStyle: TextStyle(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            )),
        controller: _subjectController,
        onSubmitted: (_) => _submitData(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customButton('Attended', '$attended', () {
                setState(() {
                  if (attended != 0) {
                    attended--;
                  }
                });
              }, () {
                setState(() {
                  attended++;
                });
              }),
              customButton('Missed', '$missed', () {
                setState(() {
                  if (missed != 0) {
                    missed--;
                  }
                });
              }, () {
                setState(() {
                  missed++;
                });
              }),
            ],
          ),
          customButton('Required', '$required %', () {
            setState(() {
              if (required != 0) {
                required -= 5;
              }
            });
          }, () {
            setState(() {
              if (required < 100) {
                required += 5;
              }
            });
          }),
        ],
      ),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          ElevatedButton(
              child: const Text('Cancel',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
              onPressed: _submitData,
              child: const Text('Add',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ])
      ],
    );
  }

  Widget customButton(String name, String num, void Function()? onRemove,
      void Function()? onAdd) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle, color: Colors.green)),
            Text(num, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle, color: Colors.green)),
          ],
        ),
        Text(name,
            style:
                const TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _submitData() {
    final enteredSubject = _subjectController.text;
    if (enteredSubject.isEmpty) return;
    widget.addAttendance(enteredSubject, attended, missed, required);
    Dialogs.showSnackBar(context, 'Subject added successfully!');
    Navigator.of(context).pop();
  }
}
