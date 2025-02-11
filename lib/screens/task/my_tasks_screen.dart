import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../secrets.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/task_widget.dart';
import '../../widgets/custom_banner_ad.dart';
import 'add_task_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  bool _isInterstitialLoaded = false;
  late InterstitialAd _interstitialAd;

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
              log('Ad failed to show: ${error.message}');
              ad.dispose();
              _initializeInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log('Failed to load interstitial ad: ${error.message}');
          setState(() {
            _isInterstitialLoaded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToTask(),
        builder: (ctx, Box<Task> box, Widget? child) {
          var tasks = box.values.toList();
          tasks.sort((a, b) => a.createdAtDate.compareTo(b.createdAtDate));

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Tasks'),
              actions: [
                if (!isFloatingActionButton)
                  IconButton(
                    onPressed: () {
                      if (_isInterstitialLoaded) _interstitialAd.show();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const AddTaskScreen(task: null)));
                    },
                    tooltip: 'Add task',
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
              ],
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar: const CustomBannerAd(),
            floatingActionButton: isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () {
                      if (_isInterstitialLoaded) _interstitialAd.show();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const AddTaskScreen(task: null)));
                    },
                    tooltip: 'Add task',
                    child: const Icon(Icons.add))
                : null,
            drawer: const MainDrawer(),
            body: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/to-do-list.png', width: 150),
                        const Text(
                          'Plan your work,\nAnd work your plan!',
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
                                    builder: (_) =>
                                        const AddTaskScreen(task: null)));
                          },
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue),
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white),
                          ),
                          child: const Text('Get started'),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mq.width * .03, vertical: mq.height * .005),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];

                        return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) {
                              return showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content:
                                      const Text('Do you want to delete this?'),
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
                            onDismissed: (_) {
                              base.dataStore.deleteTask(task: task);
                              Dialogs.showSnackBar(
                                  context, 'Task deleted successfully!');
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
                            child: TaskWidget(task: task));
                      },
                    ),
                  ),
          );
        });
  }
}
