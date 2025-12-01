import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../main.dart';
import '../../utils/dialogs.dart';
import '../../models/routine.dart';
import '../../data/hive_data_store.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_text_form_field.dart';
import '../dashboard/dashboard_screen.dart';

enum RoutineType {
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
  RoutineType _routineType = RoutineType.photo;
  late List<String> _timeSlots;
  final Map<String, Color> _subjectColorMap = {};
  final ImagePicker _picker = ImagePicker();
  final Box<Uint8List> _routineImageBox =
      Hive.box<Uint8List>('routineImageBox');
  final List<Uint8List?> _routineImages = [null, null];
  final PageController _pageController = PageController();
  final List<String> _weekdays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];

  // Master list of all available slots
  final List<String> _defaultSlots = [
    "6 AM",
    "7 AM",
    "8 AM",
    "9 AM",
    "10 AM",
    "11 AM",
    "12 PM",
    "1 PM",
    "2 PM",
    "3 PM",
    "4 PM",
    "5 PM",
    "6 PM",
    "7 PM",
    "8 PM",
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.deepPurpleAccent,
    Colors.lightGreen,
    Colors.pink,
    Colors.cyan,
    Colors.teal,
    Colors.deepOrangeAccent,
    Colors.purple,
    Colors.lime,
    Colors.indigo,
  ];

  Color _getColorForSubject(String subject) {
    if (subject.isEmpty) return Colors.transparent;
    final key = subject.toLowerCase();
    if (_subjectColorMap.containsKey(key)) return _subjectColorMap[key]!;
    final color =
        _availableColors[_subjectColorMap.length % _availableColors.length];
    _subjectColorMap[key] = color;
    return color;
  }

  Color _getTextColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  void _saveRoutineScreenState() {
    bool isPhoto = _routineType == RoutineType.photo;
    prefs.setBool('PhotoOrWeekday', isPhoto);
  }

  void _readRoutineScreenState() {
    bool? isPhoto = prefs.getBool('PhotoOrWeekday') ?? true;
    if (isPhoto) {
      setState(() {
        _routineType = RoutineType.photo;
      });
    } else {
      _routineType = RoutineType.weekdays;
    }
  }

  void _onPressedSwitchButton() {
    setState(() {
      if (_routineType == RoutineType.photo) {
        _routineType = RoutineType.weekdays;
      } else {
        _routineType = RoutineType.photo;
      }
    });
    _saveRoutineScreenState();
  }

  void _showAddSubjectSheet(String day, String time, Routine? routine) {
    final TextEditingController subjectController =
        TextEditingController(text: routine?.subject ?? "");

    // collect distinct subjects from existing routines
    final allRoutines = Hive.box<Routine>(HiveDataStore.routineBoxName).values;
    final savedSubjects = allRoutines
        .map((r) => r.subject)
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add Subject for $day, $time",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 👇 Flutter built-in autocomplete
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: subjectController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return savedSubjects.where((s) => s
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    subjectController.text = selection;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    // Pre-fill once (not on every rebuild)
                    if (controller.text.isEmpty &&
                        subjectController.text.isNotEmpty) {
                      controller.text = subjectController.text;
                    }

                    return CustomTextFormField(
                      controller: controller,
                      hintText: 'Add subject',
                      focusNode: focusNode,
                      onChanged: (val) {
                        subjectController.text = val;
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (routine != null) {
                      routine.subject = subjectController.text;
                      await routine.save();
                    } else {
                      final newRoutine = Routine(
                        id: "$day-$time",
                        day: day,
                        timeSlot: time,
                        subject: subjectController.text,
                      );
                      await BaseWidget.of(context)
                          .dataStore
                          .addRoutine(routine: newRoutine);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadImages() async {
    setState(() {
      _routineImages[0] = _routineImageBox.get('classRoutine');
      _routineImages[1] = _routineImageBox.get('examRoutine');
    });
  }

  Future<void> _pickImage(int pageIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (pageIndex == 0) {
        await _routineImageBox.put('classRoutine', bytes);
      } else if (pageIndex == 1) {
        await _routineImageBox.put('examRoutine', bytes);
      }
      _loadImages();
    }
  }

  void _loadRoutineTimeRange() {
    final start = prefs.getString('routineStart') ?? "9 AM";
    final end = prefs.getString('routineEnd') ?? "4 PM";

    int startIndex = _defaultSlots.indexOf(start);
    int endIndex = _defaultSlots.indexOf(end);

    // fallback if invalid
    if (startIndex == -1) startIndex = _defaultSlots.indexOf("9 AM");
    if (endIndex == -1) endIndex = _defaultSlots.indexOf("4 PM");

    if (startIndex <= endIndex) {
      _timeSlots = _defaultSlots.sublist(startIndex, endIndex + 1);
    } else {
      _timeSlots = _defaultSlots.sublist(
          _defaultSlots.indexOf("9 AM"), _defaultSlots.indexOf("4 PM") + 1);
    }
  }

  @override
  void initState() {
    super.initState();
    _readRoutineScreenState();
    _loadImages();
    _loadRoutineTimeRange();
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<NavigationProvider>().increment();
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const DashboardScreen()));
          },
          tooltip: 'Dashboard',
          icon: const Icon(CupertinoIcons.square_grid_2x2),
        ),
        title: const Text('Routine'),
        actions: [
          if (_routineType == RoutineType.weekdays) ...[
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Reset Routine"),
                    content: const Text(
                        "Are you sure you want to clear all subjects?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Reset",
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  ),
                );
                if (confirm == true) {
                  await BaseWidget.of(context).dataStore.clearAllRoutines();
                }
              },
              tooltip: 'Reset',
              icon: const Icon(CupertinoIcons.restart),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx) {
                    String start = _timeSlots.first;
                    String end = _timeSlots.last;

                    return StatefulBuilder(
                      builder: (ctx, setModalState) => Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Select Routine Time Range",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Start Time',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                DropdownButton<String>(
                                  value: start,
                                  borderRadius: BorderRadius.circular(10),
                                  items: _defaultSlots
                                      .map((t) => DropdownMenuItem(
                                          value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setModalState(() => start = val!),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'End Time',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                DropdownButton<String>(
                                  value: end,
                                  borderRadius: BorderRadius.circular(10),
                                  items: _defaultSlots
                                      .map((t) => DropdownMenuItem(
                                          value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setModalState(() => end = val!),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                final startIndex = _defaultSlots.indexOf(start);
                                final endIndex = _defaultSlots.indexOf(end);

                                if (startIndex > endIndex) {
                                  Navigator.pop(context);
                                  Dialogs.showErrorSnackBar(context,
                                      'Start time can\'t be greater than End time.');
                                  return;
                                }
                                if (startIndex <= endIndex) {
                                  prefs.setString('routineStart', start);
                                  prefs.setString('routineEnd', end);
                                  setState(() {
                                    _timeSlots = _defaultSlots.sublist(
                                        startIndex, endIndex + 1);
                                  });
                                  Navigator.pop(ctx);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text("Save"),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              tooltip: 'Settings',
              icon: const Icon(CupertinoIcons.gear_solid),
            ),
          ]
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: _routineType == RoutineType.photo
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _routineImages.length,
                        itemBuilder: (ctx, index) {
                          final image = _routineImages[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                index == 0
                                    ? 'Class Routine Image'
                                    : 'Exam Routine Image',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                // 👈 fixes the unbounded height issue
                                child: image == null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 100),
                                        child: Image.asset(
                                            'assets/images/calendar.png'),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: PhotoView(
                                          imageProvider: MemoryImage(image),
                                          minScale:
                                              PhotoViewComputedScale.contained,
                                          maxScale:
                                              PhotoViewComputedScale.covered *
                                                  2,
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _routineImages.length,
                      effect: WormEffect(
                        activeDotColor: Colors.blue,
                        dotHeight: 6,
                        dotWidth: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final currentPage = _pageController.page?.round() ?? 0;
                        _pickImage(currentPage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(CupertinoIcons.photo),
                      label: const Text('Add Image'),
                    ),
                    const Text(
                      'Or',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _switchButton(),
                  ],
                ),
              ),
            )
          : ValueListenableBuilder(
              valueListenable: base.dataStore.listenToRoutine(),
              builder: (ctx, Box<Routine> box, Widget? child) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: _switchButton(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        dividerThickness: .5,
                        border: TableBorder.all(color: Colors.grey.shade400),
                        columns: [
                          const DataColumn(
                            label: Text("Time"),
                            headingRowAlignment: MainAxisAlignment.start,
                          ),
                          ..._weekdays.map((day) => DataColumn(
                              label: Text(day),
                              headingRowAlignment: MainAxisAlignment.center)),
                        ],
                        rows: _timeSlots.map((time) {
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                time,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                              ..._weekdays.map((day) {
                                final routine =
                                    box.get("$day-$time"); // fetch by id
                                final subject = routine?.subject;

                                return DataCell(
                                  onTap: () =>
                                      _showAddSubjectSheet(day, time, routine),
                                  Tooltip(
                                    message:
                                        subject != null && subject.isNotEmpty
                                            ? subject
                                            : 'Add subject',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: subject != null &&
                                                subject.isNotEmpty
                                            ? _getColorForSubject(subject)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      width: 50,
                                      child: subject == null || subject.isEmpty
                                          ? Icon(
                                              Icons.add_rounded,
                                              size: 20,
                                              color: Colors.grey.shade600,
                                            )
                                          : Text(
                                              subject,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getTextColor(
                                                    _getColorForSubject(
                                                        subject)),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
    );
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
        label: Text(_routineType == RoutineType.photo
            ? 'Switch to WeekDay'
            : 'Switch to Picture'));
  }
}
