import 'package:flutter/material.dart';

class IssuedPage extends StatelessWidget {
  const IssuedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(child: Text('List of issued books will go here')),
    );
  }
}
