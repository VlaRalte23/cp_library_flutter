import 'package:flutter/material.dart';

class ReturnedPage extends StatelessWidget {
  const ReturnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Returned Books'),
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
