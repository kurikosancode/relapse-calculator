import 'package:flutter/material.dart';

class TextInputButton extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback submitFunction;

  const TextInputButton(
      {super.key, required this.textController, required this.submitFunction});

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Type here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                submitFunction();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Button background
            foregroundColor: Colors.white, // Text/icon color
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _showInputDialog(context);
          },
          child: const Text('Add Clear Message'),
        ),
      ),
    );
  }
}
