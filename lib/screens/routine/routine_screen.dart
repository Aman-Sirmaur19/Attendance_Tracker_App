import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../main.dart';
import '../../services/ad_manager.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../providers/settings_provider.dart';
import '../dashboard_screen.dart';

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

  void _saveRoutineScreenState() {
    bool isPhoto = _routine == Routine.photo;
    prefs.setBool('PhotoOrWeekday', isPhoto);
  }

  void _readRoutineScreenState() {
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
    _readRoutineScreenState();
    _loadImage();
    _loadSubjects();
  }

  void _loadSubjects() {
    for (int i = 0; i < daysOfWeek.length; i++) {
      List<String>? savedSubjects = prefs.getStringList('subjects_$i');
      if (savedSubjects != null) {
        subjects[i].addAll(savedSubjects);
      }
    }
    setState(() {});
  }

  void _onPressedSwitchButton() {
    setState(() {
      if (_routine == Routine.photo) {
        _routine = Routine.weekdays;
      } else {
        _routine = Routine.photo;
      }
    });
    _saveRoutineScreenState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () =>
                AdManager().navigateWithAd(context, const DashboardScreen()),
            tooltip: 'Dashboard',
            icon: const Icon(CupertinoIcons.square_grid_2x2),
          ),
          title: const Text('Routine'),
          actions: [
            IconButton(
              onPressed: _onPressedSwitchButton,
              tooltip: _routine == Routine.photo
                  ? 'Switch to WeekDay mode'
                  : 'Switch to Picture mode',
              icon: Icon(
                _routine == Routine.photo
                    ? CupertinoIcons.calendar_today
                    : CupertinoIcons.photo,
                color: Colors.deepPurpleAccent,
              ),
            ),
            if (_routine == Routine.weekdays &&
                !settingsProvider.isFloatingActionButton)
              IconButton(
                onPressed: () => _addSubject(_pageController.page!.toInt()),
                tooltip: 'Add routine',
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
          ],
        ),
        bottomNavigationBar: const CustomBannerAd(),
        floatingActionButton: (_routine == Routine.weekdays &&
                settingsProvider.isFloatingActionButton)
            ? FloatingActionButton(
                onPressed: () => _addSubject(_pageController.page!.toInt()),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                tooltip: 'Add routine',
                child: const Icon(Icons.add))
            : null,
        body: _routine == Routine.photo
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageBytes == null
                        ? Image.asset('assets/images/calendar.png', width: 150)
                        : SizedBox(
                            height: 350,
                            child: PhotoView(
                              imageProvider: MemoryImage(_imageBytes!),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                            )),
                    if (_imageBytes != null) const SizedBox(height: 8),
                    ElevatedButton.icon(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(CupertinoIcons.photo),
                        label: const Text('Add Routine Image')),
                    const Text(
                      'Or',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _switchButton(),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: daysOfWeek.length,
                      itemBuilder: (context, index) {
                        return _buildDayPage(index);
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
              ));
  }

  Widget _switchButton() {
    return ElevatedButton.icon(
        onPressed: _onPressedSwitchButton,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(CupertinoIcons.arrow_swap),
        label: Text(_routine == Routine.photo
            ? 'Switch to WeekDay'
            : 'Switch to Picture'));
  }

  Widget _buildDayPage(int dayIndex) {
    return Padding(
      padding: EdgeInsets.all(mq.width * .03),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _switchButton(),
            Text(
              daysOfWeek[dayIndex],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subjects[dayIndex].isEmpty
                ? Center(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15),
                        const Text(
                          'No routine added yet!',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
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
                      String timeInfo = infoParts[1];

                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subjectName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    timeInfo,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  subjects[dayIndex].removeAt(subjectIndex);
                                  _saveSubjects(dayIndex);
                                });
                              },
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _saveSubjects(int dayIndex) {
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
                decoration: InputDecoration(
                  hintText: 'Subject Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.lightBlue),
                  ),
                ),
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
                    _saveSubjects(index);
                  });
                  subjectController.clear();
                  startTime = null;
                  endTime = null;
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                subjectController.clear();
                startTime = null;
                endTime = null;
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}
