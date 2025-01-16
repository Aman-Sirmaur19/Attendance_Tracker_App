import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../main.dart';
import '../../secrets.dart';
import '../../models/attendance.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/custom_banner_ad.dart';
import 'add_notes_screen.dart';

class NotesScreen extends StatefulWidget {
  final Attendance attendance;
  final List<Map<String, dynamic>> notes;

  const NotesScreen({super.key, required this.attendance, required this.notes});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isInterstitialLoaded = false;
  late InterstitialAd _interstitialAd;
  final List<Color> _colors = [
    Colors.amber,
    Colors.lightGreen,
    Colors.pink,
    Colors.blue,
    Colors.lime,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _initializeInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd.dispose();
  }

  void _initializeInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: Secrets.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          setState(() {
            _isInterstitialLoaded = true;
          });
          _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _initializeInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              dev.log('Ad failed to show: ${error.message}');
              ad.dispose();
              _initializeInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          dev.log('Failed to load interstitial ad: ${error.message}');
          setState(() {
            _isInterstitialLoaded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sticky Notes'),
        actions: [
          if (!isFloatingActionButton)
            IconButton(
              onPressed: () {
                if (_isInterstitialLoaded) _interstitialAd.show();
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) =>
                            AddNotesScreen(attendance: widget.attendance)));
              },
              tooltip: 'Add note',
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_isInterstitialLoaded) _interstitialAd.show();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => AddNotesScreen(
                                  attendance: widget.attendance)));
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    child: const Text('Get started'),
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
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => AddNotesScreen(
                                attendance: widget.attendance,
                                note: widget.notes[index],
                              ))),
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
                                  Icons.delete_rounded,
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
                child: const Text('Yes'),
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
              child: const Text('No'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ])
        ],
      ),
    );
  }
}
