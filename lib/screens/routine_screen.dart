import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../main.dart';
import '../widgets/main_drawer.dart';

enum Routine {
  photo,
  weekdays,
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen>
    with SingleTickerProviderStateMixin {
  Routine _routine = Routine.photo;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  final Box _routineBox = Hive.box('routineImageBox');
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
  late AnimationController animationController;
  bool isDrawerOpen = false;
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();

  void saveRoutineScreenState() {
    bool isPhoto = _routine == Routine.photo;
    prefs.setBool('PhotoOrWeekday', isPhoto);
  }

  void readRoutineScreenState() {
    bool? isPhoto = prefs.getBool('PhotoOrWeekday') ?? true;
    if (isPhoto) {
      setState(() {
        _routine = Routine.photo;
      });
    } else {
      _routine = Routine.weekdays;
    }
  }

  Future<void> _loadImage() async {
    final imageBytes = _routineBox.get('routineImage') as Uint8List?;
    setState(() {
      _imageBytes = imageBytes;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _saveImage(bytes);
    }
  }

  Future<void> _saveImage(Uint8List bytes) async {
    await _routineBox.put('routineImage', bytes);
    setState(() {
      _imageBytes = bytes;
    });
  }

  @override
  void initState() {
    super.initState();
    readRoutineScreenState();
    _loadImage();
    loadSubjects();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void onDrawerToggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        animationController.forward();
        drawerKey.currentState!.openSlider();
      } else {
        animationController.reverse();
        drawerKey.currentState!.closeSlider();
      }
    });
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

  void onPressedSwitchButton() {
    setState(() {
      if (_routine == Routine.photo) {
        _routine = Routine.weekdays;
      } else {
        _routine = Routine.photo;
      }
    });
    saveRoutineScreenState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SliderDrawer(
      key: drawerKey,
      isDraggable: false,
      animationDuration: 1000,
      appBar: AppBar(
        leading: IconButton(
          onPressed: onDrawerToggle,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: animationController,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Routine',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: onPressedSwitchButton,
            tooltip: _routine == Routine.photo
                ? 'Switch to WeekDay mode'
                : 'Switch to Picture mode',
            icon: Icon(_routine == Routine.photo
                ? CupertinoIcons.calendar_today
                : CupertinoIcons.photo),
          ),
          if (_routine == Routine.weekdays)
            IconButton(
              onPressed: () => _addSubject(_pageController.page!.toInt()),
              tooltip: 'Add routine',
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      slider: const MainDrawer(),
      child: _routine == Routine.photo
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _imageBytes == null
                    ? const Icon(CupertinoIcons.calendar_today, size: 250)
                    : SizedBox(
                        height: mq.height * .5,
                        child: PhotoView(
                          imageProvider: MemoryImage(_imageBytes!),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        )),
                if (_imageBytes != null) const SizedBox(height: 8),
                ElevatedButton.icon(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue),
                    icon: const Icon(CupertinoIcons.photo),
                    label: const Text('Add Routine Image')),
                TextButton.icon(
                    onPressed: onPressedSwitchButton,
                    icon: const Icon(CupertinoIcons.arrow_swap),
                    label: Text(_routine == Routine.photo
                        ? 'Switch to WeekDay'
                        : 'Switch to Picture')),
              ],
            )
          : Column(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: daysOfWeek.length,
                    effect: const WormEffect(
                      activeDotColor: Colors.blue,
                      spacing: 5,
                      dotWidth: 7,
                      dotHeight: 7,
                    ),
                  ),
                ),
              ],
            ),
    ));
  }

  Widget buildDayPage(int dayIndex) {
    return Padding(
      padding: EdgeInsets.all(mq.width * .03),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextButton.icon(
                onPressed: onPressedSwitchButton,
                icon: const Icon(CupertinoIcons.arrow_swap),
                label: Text(_routine == Routine.photo
                    ? 'Switch to WeekDay'
                    : 'Switch to Picture')),
            Text(
              daysOfWeek[dayIndex],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subjects[dayIndex].isEmpty
                ? Center(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15),
                        Text(
                          'No routine added yet!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(.67),
                          ),
                        ),
                        SizedBox(height: mq.height * .04),
                        SizedBox(
                          height: mq.height * 0.4,
                          child: Image.asset(
                            'assets/images/waiting.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
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
