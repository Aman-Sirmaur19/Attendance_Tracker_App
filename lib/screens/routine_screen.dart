import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../main.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final PageController _pageController =
      PageController(initialPage: DateTime.now().weekday - 1);
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<List<String>> subjects = List.generate(7, (_) => []);

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  void loadSubjects() {
    for (int i = 0; i < daysOfWeek.length; i++) {
      List<String>? savedSubjects = prefs.getStringList('subjects_$i');
      if (savedSubjects != null) {
        subjects[i].addAll(savedSubjects);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addSubject(_pageController.page!.toInt()),
          tooltip: 'Add subject',
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  return buildDayPage(index);
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: daysOfWeek.length,
              effect: const WormEffect(activeDotColor: Colors.blue),
            ),
          ],
        ));
  }

  Widget buildDayPage(int dayIndex) {
    return Padding(
      padding: EdgeInsets.all(mq.width * .03),
      child: Column(
        children: [
          Text(
            daysOfWeek[dayIndex],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: subjects[dayIndex].length,
            itemBuilder: (context, subjectIndex) {
              String subjectInfo = subjects[dayIndex][subjectIndex];
              List<String> infoParts = subjectInfo.split(' - ');
              String subjectName = infoParts[0];
              String timeInfo = infoParts[
                  1]; // Assuming time info is formatted as 'Starting Time to Ending Time'

              return Card(
                child: ListTile(
                  title: Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    timeInfo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        subjects[dayIndex].removeAt(subjectIndex);
                        saveSubjects(dayIndex);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void saveSubjects(int dayIndex) {
    prefs.setStringList('subjects_$dayIndex', subjects[dayIndex]);
  }

  void _addSubject(int index) async {
    TextEditingController subjectController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    void showStartTimePicker() async {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          startTime = selectedTime;
        });
      }
    }

    void showEndTimePicker() async {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          endTime = selectedTime;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              ListTile(
                title: Text(
                    'Starting Time: ${startTime?.format(context) ?? 'Not set'}'),
                onTap: showStartTimePicker,
              ),
              ListTile(
                title: Text(
                    'Ending Time: ${endTime?.format(context) ?? 'Not set'}'),
                onTap: showEndTimePicker,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (subjectController.text.isNotEmpty &&
                    startTime != null &&
                    endTime != null) {
                  String subjectName = subjectController.text;
                  String startTimeFormatted = startTime!.format(context);
                  String endTimeFormatted = endTime!.format(context);
                  String subjectInfo =
                      '$subjectName - $startTimeFormatted to $endTimeFormatted';
                  setState(() {
                    subjects[index].add(subjectInfo);
                    saveSubjects(index);
                  });
                  subjectController.clear();
                  startTime = null;
                  endTime = null;
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                subjectController.clear();
                startTime = null;
                endTime = null;
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
