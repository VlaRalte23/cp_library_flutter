import 'package:flutter/material.dart';

class NotReturnedPage extends StatelessWidget {
  const NotReturnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lehkhabu La Dah Let Loh',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(child: Text('List of Not Return books will go here')),
    );
  }
}
