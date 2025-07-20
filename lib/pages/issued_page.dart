import 'package:flutter/material.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class IssuedPage extends StatelessWidget {
  const IssuedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issued Books')),
      drawer: AppDrawer(),
      body: const Center(child: Text('List of issued books will go here')),
    );
  }
}
