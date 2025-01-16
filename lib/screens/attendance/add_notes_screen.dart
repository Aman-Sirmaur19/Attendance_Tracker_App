import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/attendance.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_text_form_field.dart';

class AddNotesScreen extends StatefulWidget {
  final Attendance attendance;
  final Map<String, dynamic>? note;

  const AddNotesScreen({super.key, required this.attendance, this.note});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note?['title'];
      _descriptionController.text = widget.note?['description'];
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  // if any note already exist return true, else false
  bool _isNoteAlreadyExist() {
    if (widget.note != null) {
      return true;
    } else {
      return false;
    }
  }

  // Main function for creating & editing note
  dynamic _createAndEdit() async {
    // update current attendance
    if (_titleController.text.trim().isNotEmpty && widget.note != null) {
      try {
        widget.note?['title'] = _titleController.text.trim();
        widget.note?['description'] = _descriptionController.text.trim();
        widget.attendance.save();
        Dialogs.showSnackBar(context, 'Sticky note updated successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else if (_titleController.text.trim().isNotEmpty) {
      try {
        Map<String, dynamic> note = {};
        note['title'] = _titleController.text.trim();
        if (_descriptionController.text.trim().isNotEmpty) {
          note['description'] = _descriptionController.text.trim();
        } else {
          note['description'] = '';
        }
        widget.attendance.notes.add(note);
        widget.attendance.save();
        Dialogs.showSnackBar(context, 'Sticky note added successfully!');
        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
      }
    } else {
      Dialogs.showErrorSnackBar(context, 'Enter title');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
              _isNoteAlreadyExist() ? 'Update Sticky Note' : 'Add Sticky Note'),
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _customText('Enter title'),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _titleController,
              hintText: 'Title',
              onFieldSubmitted: (value) {
                _titleController.text = value;
              },
            ),
            const SizedBox(height: 20),
            _customText('Enter description'),
            const SizedBox(height: 5),
            CustomTextFormField(
              controller: _descriptionController,
              hintText: 'Description',
              onFieldSubmitted: (value) {
                _descriptionController.text = value;
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => setState(() => _createAndEdit()),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue),
              icon: Icon(_isNoteAlreadyExist()
                  ? CupertinoIcons.refresh_thick
                  : CupertinoIcons.list_bullet_indent),
              label: Text(_isNoteAlreadyExist() ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
