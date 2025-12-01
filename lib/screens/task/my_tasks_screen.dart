import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/task.dart';
import '../../utils/dialogs.dart';
import '../../providers/settings_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/task_widget.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_elevated_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'add_task_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToTask(),
        builder: (ctx, Box<Task> box, Widget? child) {
          var tasks = box.values.toList();
          tasks.sort((a, b) => a.createdAtDate.compareTo(b.createdAtDate));

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
              title: const Text('My Tasks'),
              actions: [
                if (!settingsProvider.isFloatingActionButton)
                  IconButton(
                    onPressed: () {
                      context.read<NavigationProvider>().increment();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  const AddTaskScreen(task: null)));
                    },
                    tooltip: 'Add task',
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  )
              ],
            ),
            bottomNavigationBar: const CustomBannerAd(),
            floatingActionButton: settingsProvider.isFloatingActionButton
                ? FloatingActionButton(
                    onPressed: () {
                      context.read<NavigationProvider>().increment();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  const AddTaskScreen(task: null)));
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    tooltip: 'Add task',
                    child: const Icon(Icons.add))
                : null,
            body: tasks.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/to-do-list.png',
                              width: 150),
                          const Text(
                            'Plan your work,\nAnd work your plan!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomElevatedButton(
                            onPressed: () {
                              context.read<NavigationProvider>().increment();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const AddTaskScreen(task: null)));
                            },
                            title: 'Get started',
                          )
                        ],
                      ),
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
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              }),
                                          TextButton(
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                              ),
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
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                context.read<NavigationProvider>().increment();
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            AddTaskScreen(task: task)));
                              },
                              child: TaskWidget(task: task),
                            ));
                      },
                    ),
                  ),
          );
        });
  }
}
