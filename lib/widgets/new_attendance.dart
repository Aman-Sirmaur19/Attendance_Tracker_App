import 'package:flutter/material.dart';

import '../main.dart';

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

  void _submitData() {
    final enteredSubject = _subjectController.text;
    if (enteredSubject.isEmpty) return;
    widget.addAttendance(enteredSubject, attended, missed, required);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
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
              Column(
                children: [
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (attended != 0) {
                              attended--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.green)),
                    Text('$attended',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            attended++;
                          });
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.green))
                  ]),
                  const Text('Attended',
                      style: TextStyle(
                          letterSpacing: 1, fontWeight: FontWeight.bold))
                ],
              ),
              Column(
                children: [
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (missed != 0) {
                              missed--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.green)),
                    Text('$missed',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            missed++;
                          });
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.green))
                  ]),
                  const Text('Missed',
                      style: TextStyle(
                          letterSpacing: 1, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: mq.height * .03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (required != 0) {
                                required -= 5;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.green)),
                      Text('$required %',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (required < 100) {
                                required += 5;
                              }
                            });
                          },
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green))
                    ]),
                    const Text('Required',
                        style: TextStyle(
                            letterSpacing: 1, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
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
}
