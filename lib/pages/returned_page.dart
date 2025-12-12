import 'package:flutter/material.dart';

class ReturnedPage extends StatelessWidget {
  const ReturnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lehkhabu Dah Let Ho',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(child: Text('List of Return books will go here')),
    );
  }
}
