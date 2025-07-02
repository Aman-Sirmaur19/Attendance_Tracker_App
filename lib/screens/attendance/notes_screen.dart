import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/dialogs.dart';
import '../../models/attendance.dart';
import '../../services/ad_manager.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../providers/settings_provider.dart';
import 'add_notes_screen.dart';

class NotesScreen extends StatefulWidget {
  final Attendance attendance;
  final List<Map<String, dynamic>> notes;

  const NotesScreen({super.key, required this.attendance, required this.notes});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Color> _colors = [
    Colors.amber,
    Colors.lightGreen,
    Colors.pink,
    Colors.blue,
    Colors.lime,
    Colors.red,
    Colors.orange,
    Colors.deepPurpleAccent,
    Colors.cyan,
    Colors.indigoAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sticky Notes'),
        actions: [
          if (!settingsProvider.isFloatingActionButton)
            IconButton(
              onPressed: () => AdManager().navigateWithAd(
                  context, AddNotesScreen(attendance: widget.attendance)),
              tooltip: 'Add note',
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      floatingActionButton: settingsProvider.isFloatingActionButton
          ? FloatingActionButton(
              onPressed: () => AdManager().navigateWithAd(
                  context, AddNotesScreen(attendance: widget.attendance)),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              tooltip: 'Add task',
              child: const Icon(Icons.add))
          : null,
      body: widget.notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/sticky-notes.png', width: 130),
                  const Text(
                    'Capture your thoughts before\nthey fly away!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomElevatedButton(
                    onPressed: () => AdManager().navigateWithAd(
                        context, AddNotesScreen(attendance: widget.attendance)),
                    title: 'Get started',
                  )
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 150,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final Color randomColor =
                    _colors[Random().nextInt(_colors.length)];
                return GestureDetector(
                  onTap: () => AdManager().navigateWithAd(
                      context,
                      AddNotesScreen(
                        attendance: widget.attendance,
                        note: widget.notes[index],
                      )),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: randomColor.withOpacity(.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: randomColor.withOpacity(.6)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        ListTile(
                          title: Text(
                            widget.notes[index]['title'],
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: widget.notes[index]['description'] != ''
                              ? Text(
                                  widget.notes[index]['description'],
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey),
                                )
                              : null,
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                onPressed: () => _deleteNote(index),
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to delete this?'),
        actions: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    widget.attendance.notes.removeAt(index);
                    widget.attendance.save();
                    Dialogs.showSnackBar(
                        context, 'Sticky note deleted successfully!');
                  });
                  Navigator.of(ctx).pop(true);
                }),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'No',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
