import 'package:flutter/material.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class MagazinePage extends StatelessWidget {
  const MagazinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magazines')),
      drawer: AppDrawer(),
      body: const Center(child: Text('List of Magazines will go here')),
    );
  }
}
