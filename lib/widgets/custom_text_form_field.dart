import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: Colors.blue,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: hintText == 'Description' || hintText == 'Add note' ? null : 1,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(
        prefixIcon: hintText == 'Description' || hintText == 'Add note'
            ? const Icon(Icons.bookmark_border_rounded, color: Colors.grey)
            : hintText == 'Plan'
                ? const Icon(Icons.sports_gymnastics_rounded,
                    color: Colors.grey)
                : hintText == 'Subject'
                    ? const Icon(Icons.stacked_bar_chart_rounded,
                        color: Colors.grey)
                    : const Icon(Icons.title_rounded, color: Colors.grey),
        hintText: hintText,
        hintStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
