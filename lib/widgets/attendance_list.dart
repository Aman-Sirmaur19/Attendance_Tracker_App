import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../models/attendance.dart';
import '../widgets/chart_bar.dart';

class AttendanceList extends StatefulWidget {
  final List<Attendance> attendances;
  final Function deleteAttendance;
  final Function editAttendance;
  final Function editSubjectName;

  const AttendanceList(this.attendances, this.deleteAttendance,
      this.editAttendance, this.editSubjectName,
      {super.key});

  @override
  State<AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  int _expandedIndex = -1;
  int _editIndex = -1;

  final _subjectController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.attendances.isEmpty
        ? Center(
            child: Stack(
              children: <Widget>[
                const Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Text(
                    'No subjects added yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Lottie.asset('assets/lottie/books.json'),
              ],
            ),
          )
        : GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.attendances.length,
                itemBuilder: (ctx, index) {
                  final isExpanded = _expandedIndex == index;
                  final DateTime dateTime =
                      DateTime.parse(widget.attendances[index].time);
                  final String date = DateFormat.yMMMd().format(dateTime);
                  final String time = DateFormat('hh:mm a').format(dateTime);

                  final isEdit = _editIndex == index;

                  ///---------------------------------------------------------------
                  final total = widget.attendances[index].present +
                      widget.attendances[index].absent;
                  double required =
                      (total * widget.attendances[index].requirement) -
                          widget.attendances[index].present * 100;
                  required /= (100 - widget.attendances[index].requirement);
                  double miss = (100.0 * widget.attendances[index].present) -
                      (widget.attendances[index].requirement * (total));
                  miss /= widget.attendances[index].requirement;
                  final percentage =
                      (widget.attendances[index].present * 100) / (total);

                  ///---------------------------------------------------------------
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                          widget.deleteAttendance(widget.attendances[index].id);
                          if (_expandedIndex == index) {
                            _expandedIndex = -1;
                          } else if (_expandedIndex > index) {
                            _expandedIndex--;
                          }
                        });
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.error,
                        ),
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
                                  leading: total == 0
                                      ? Image.asset('assets/images/owl.png')
                                      : CircleAvatar(
                                          radius: mq.width * .08,
                                          child: FittedBox(
                                              child: Text(
                                                  '${percentage.toStringAsFixed(0)}%')),
                                        ),
                                  title: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        isEdit
                                            ? SizedBox(
                                                width: mq.width * .4,
                                                child: TextField(
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  autofocus: true,
                                                  controller:
                                                      _subjectController,
                                                ),
                                              )
                                            : Text(
                                                widget
                                                    .attendances[index].subject,
                                                style: const TextStyle(
                                                    letterSpacing: 1,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        isEdit
                                            ? IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (_subjectController
                                                            .text.isNotEmpty &&
                                                        _subjectController
                                                                .text !=
                                                            widget
                                                                .attendances[
                                                                    index]
                                                                .subject) {
                                                      widget.attendances[index]
                                                              .time =
                                                          DateTime.now()
                                                              .toString();
                                                    }
                                                    _submitData(widget
                                                        .attendances[index].id);
                                                    _editIndex = isEdit
                                                        ? -1
                                                        : index; // Toggle expanded state
                                                  });
                                                },
                                                icon: const Icon(Icons.save))
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _subjectController.text =
                                                        widget
                                                            .attendances[index]
                                                            .subject;
                                                    _editIndex = isEdit
                                                        ? -1
                                                        : index; // Toggle expanded state
                                                  });
                                                },
                                                icon: const Icon(Icons.edit))
                                      ],
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        EdgeInsets.only(top: mq.height * .005),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            Text(
                                                'Req.: ${widget.attendances[index].requirement} %',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green)),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: mq.height * .005),
                                          child: Text(
                                              'Last updated: $time\n$date',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                        ),
                                        if (widget.attendances[index].present +
                                                widget.attendances[index]
                                                    .absent !=
                                            0)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: mq.height * .005),
                                            child: TweenAnimationBuilder(
                                              tween: Tween<double>(
                                                  begin: 0,
                                                  end: percentage / 100),
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              builder: (context, double value,
                                                      child) =>
                                                  ChartBar(value),
                                            ),
                                          ),
                                        if (required > 0)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: mq.height * .005),
                                            child: Text(
                                              required <= 1
                                                  ? 'Attend 1 class.'
                                                  : widget.attendances[index]
                                                              .requirement ==
                                                          100
                                                      ? 'Attend $required classes in a row.'
                                                      : 'Attend ${required.ceil()} classes in a row.',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else if (miss >= 1)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: mq.height * .005),
                                            child: Text(
                                              miss >= 2
                                                  ? 'Can miss ${miss.floor()} classes in a row.'
                                                  : 'Can miss 1 class.',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: mq.height * .005),
                                            child: const Text(
                                              "Can't miss any class",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded) expandedContent(index)
                              ],
                            ),
                          )),
                    ),
                  );
                }),
          );
  }

  Widget expandedContent(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        customButton(
          index,
          'Attended',
          '${widget.attendances[index].present}',
          () {
            setState(() {
              if (widget.attendances[index].present != 0) {
                widget.attendances[index].present--;
                widget.attendances[index].time = DateTime.now().toString();
              }
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
          () {
            setState(() {
              widget.attendances[index].present++;
              widget.attendances[index].time = DateTime.now().toString();
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
        ),
        customButton(
          index,
          'Missed',
          '${widget.attendances[index].absent}',
          () {
            setState(() {
              if (widget.attendances[index].absent != 0) {
                widget.attendances[index].absent--;
                widget.attendances[index].time = DateTime.now().toString();
              }
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
          () {
            setState(() {
              widget.attendances[index].absent++;
              widget.attendances[index].time = DateTime.now().toString();
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
        ),
        customButton(
          index,
          'Required',
          '${widget.attendances[index].requirement}%',
          () {
            setState(() {
              if (widget.attendances[index].requirement != 0) {
                widget.attendances[index].requirement -= 5;
                widget.attendances[index].time = DateTime.now().toString();
              }
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
          () {
            setState(() {
              if (widget.attendances[index].requirement < 100) {
                widget.attendances[index].requirement += 5;
                widget.attendances[index].time = DateTime.now().toString();
              }
            });
            widget.editAttendance(
              widget.attendances[index].id,
              widget.attendances[index].present,
              widget.attendances[index].absent,
              widget.attendances[index].requirement,
            );
          },
        ),
      ],
    );
  }

  Widget customButton(int index, String name, String num,
      void Function()? onRemove, void Function()? onAdd) {
    return Column(
      children: [
        Row(
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
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }

  void _submitData(String id) {
    final enteredSubject = _subjectController.text;
    if (enteredSubject.isEmpty) return;
    widget.editSubjectName(id, enteredSubject);
    _subjectController.clear();
  }
}
