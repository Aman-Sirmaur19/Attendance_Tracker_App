import 'package:flutter/material.dart';

class FeedbackService {
  static final TextEditingController _controller = TextEditingController();

  static Widget builder(
    BuildContext context,
    Future<void> Function(String, {Map<String, dynamic>? extras}) onSubmit,
    ScrollController? scrollController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Send Feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Please describe your issue or suggestion:',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Fredoka',
                ),
                decoration: InputDecoration(
                  hintText: 'Write your feedback here...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text(
                  'Submit Feedback',
                  style: TextStyle(fontFamily: 'Fredoka'),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () async {
                  final userMessage = _controller.text.trim();
                  if (userMessage.isEmpty) return;

                  await onSubmit(userMessage, extras: {'sendEmail': true});
                  _controller.clear(); // clear after sending
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
