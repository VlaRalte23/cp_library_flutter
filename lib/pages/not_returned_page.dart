import 'package:flutter/material.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class NotReturnedPage extends StatelessWidget {
  const NotReturnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Return Books')),
      drawer: AppDrawer(),
      body: const Center(child: Text('List of Not Return books will go here')),
    );
  }
}
