import 'package:flutter/material.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class ReturnedPage extends StatelessWidget {
  const ReturnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returned Books')),
      drawer: AppDrawer(),
      body: const Center(child: Text('List of Return books will go here')),
    );
  }
}
