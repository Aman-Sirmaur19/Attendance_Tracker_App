import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/task_widget.dart';
import '../../widgets/custom_banner_ad.dart';
import 'add_task_screen.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

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
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const AddTaskScreen(task: null))),
                    tooltip: 'Add task',
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
              ],
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar: const CustomBannerAd(),
            floatingActionButton: isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const AddTaskScreen(task: null))),
                    tooltip: 'Add task',
                    child: const Icon(Icons.add))
                : null,
            drawer: const MainDrawer(),
            body: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No task to do!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Lottie.asset('assets/lottie/checklist.json'),
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
