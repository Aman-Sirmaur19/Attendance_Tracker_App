import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/attendance.dart';
import '../widgets/chart_bar.dart';

class AttendanceList extends StatefulWidget {
  final List<Attendance> attendances;
  final Function deleteAttendance;
  final Function editAttendance;

  const AttendanceList(
      this.attendances, this.deleteAttendance, this.editAttendance,
      {super.key});

  @override
  State<AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return widget.attendances.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: mq.height * .05),
                    child: Text(
                      'No subjects added yet!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.67),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  SizedBox(
                    height: constraints.maxHeight * 0.6,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
            );
          })
        : ListView.builder(
            itemCount: widget.attendances.length,
            itemBuilder: (ctx, index) {
              final isExpanded = _expandedIndex == index;
              final DateTime dateTime =
                  DateTime.parse(widget.attendances[index].time);
              final String date = DateFormat.yMMMd().format(dateTime);
              final String time = DateFormat('hh:mm a').format(dateTime);

              ///----------------------------------------------------------------------------
              final total = widget.attendances[index].present +
                  widget.attendances[index].absent;
              double required =
                  (total * widget.attendances[index].requirement) -
                      widget.attendances[index].present * 100;
              required /= (100 - widget.attendances[index].requirement);
              final percentage = (widget.attendances[index].present * 100) /
                  (widget.attendances[index].present +
                      widget.attendances[index].absent);

              ///----------------------------------------------------------------------------
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq.width * .03, vertical: mq.height * .005),
                child: Dismissible(
                  key: ValueKey(widget.attendances[index].id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('Do you want to delete this?'),
                        actions: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(true);
                                    }),
                                TextButton(
                                    child: const Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    }),
                              ])
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    setState(() {
                      widget.deleteAttendance(
                          widget.attendances[index].id);
                      if (_expandedIndex == index) {
                        _expandedIndex = -1;
                      } else if (_expandedIndex > index) {
                        _expandedIndex--;
                      }
                    });
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                      elevation: 3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded
                                ? -1
                                : index; // Toggle expanded state
                          });
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                radius: mq.width * .08,
                                child: FittedBox(
                                    child: Text(
                                        '${percentage.toStringAsFixed(0)}%')),
                              ),
                              title: Text(widget.attendances[index].subject,
                                  style: const TextStyle(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: mq.height * .005),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Attended: ${widget.attendances[index].present}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue)),
                                        Text(
                                            'Missed: ${widget.attendances[index].absent}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red)),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: mq.height * .005),
                                      child: Text('Last updated: $time $date',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                    ),
                                    if (widget.attendances[index].present +
                                            widget.attendances[index].absent !=
                                        0)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: mq.height * .005),
                                        child: ChartBar(percentage / 100),
                                      ),
                                    if (required > 0)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: mq.height * .005),
                                        child: Text(required == 1
                                            ? 'Attend ${(required).toInt()} class.'
                                            : 'Attend ${(required).toInt()} classes in a row.'),
                                      ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  widget.deleteAttendance(
                                      widget.attendances[index].id);
                                  if (_expandedIndex == index) {
                                    _expandedIndex = -1;
                                  } else if (_expandedIndex > index) {
                                    _expandedIndex--;
                                  }
                                },
                              ),
                            ),
                            if (isExpanded)
                              Row(children: [
                                Column(
                                  children: [
                                    Row(children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (widget.attendances[index]
                                                      .present !=
                                                  0) {
                                                widget.attendances[index]
                                                    .present--;
                                                widget.attendances[index].time =
                                                    DateTime.now().toString();
                                              }
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.green)),
                                      Text(
                                          '${widget.attendances[index].present}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              widget
                                                  .attendances[index].present++;
                                              widget.attendances[index].time =
                                                  DateTime.now().toString();
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green))
                                    ]),
                                    const Text('Attended',
                                        style: TextStyle(
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (widget.attendances[index]
                                                      .absent !=
                                                  0) {
                                                widget.attendances[index]
                                                    .absent--;
                                                widget.attendances[index].time =
                                                    DateTime.now().toString();
                                              }
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.green)),
                                      Text(
                                          '${widget.attendances[index].absent}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              widget
                                                  .attendances[index].absent++;
                                              widget.attendances[index].time =
                                                  DateTime.now().toString();
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green))
                                    ]),
                                    const Text('Missed',
                                        style: TextStyle(
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (widget.attendances[index]
                                                      .requirement !=
                                                  0) {
                                                widget.attendances[index]
                                                    .requirement -= 5;
                                                widget.attendances[index].time =
                                                    DateTime.now().toString();
                                              }
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.green)),
                                      Text(
                                          '${widget.attendances[index].requirement}%',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (widget.attendances[index]
                                                      .requirement <
                                                  100) {
                                                widget.attendances[index]
                                                    .requirement += 5;
                                                widget.attendances[index].time =
                                                    DateTime.now().toString();
                                              }
                                            });
                                            widget.editAttendance(
                                              widget.attendances[index].id,
                                              widget.attendances[index].present,
                                              widget.attendances[index].absent,
                                              widget.attendances[index]
                                                  .requirement,
                                            );
                                          },
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green))
                                    ]),
                                    const Text('Required',
                                        style: TextStyle(
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold))
                                  ],
                                )
                              ])
                          ],
                        ),
                      )),
                ),
              );
            });
  }
}
