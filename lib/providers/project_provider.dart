import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  String? _selectedProjectId;

  String? get selectedProjectId => _selectedProjectId;

  void selectProject(String id) {
    _selectedProjectId = id;
    notifyListeners();
  }

  void clearSelection() {
    _selectedProjectId = null;
    notifyListeners();
  }
}
