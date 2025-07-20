import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:library_chawnpui/helper/hive_services.dart';
import 'package:library_chawnpui/models/book.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(BookAdapter());
  await Hive.openBox<Member>('member');
  await Hive.openBox<Book>('books');
  await HiveService().init();

  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const LibraryDashboardPage(),
    );
  }
}
