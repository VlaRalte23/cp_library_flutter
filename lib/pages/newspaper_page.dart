import 'package:flutter/material.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class NewspaperPage extends StatelessWidget {
  const NewspaperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Newspaper')),
      drawer: AppDrawer(),
      body: const Center(child: Text('List of Newspaper will go here')),
    );
  }
}
