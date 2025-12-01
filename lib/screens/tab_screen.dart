import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'task/my_tasks_screen.dart';
import 'games/all_games_screen.dart';
import 'project/project_screen.dart';
import 'routine/routine_screen.dart';
import 'attendance/attendance_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      {'page': const AttendanceScreen()},
      {'page': const RoutineScreen()},
      {'page': const ProjectScreen()},
      {'page': const MyTasksScreen()},
      {'page': const AllGamesScreen()},
    ];
  }

  void _selectPage(int index) {
    context.read<NavigationProvider>().increment();
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Theme.of(context).colorScheme.secondaryContainer,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_rounded),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar_today),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.layers_alt),
            label: 'Project',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet_indent),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gamecontroller),
            label: 'Mini-Games',
          ),
        ],
      ),
    );
  }
}
