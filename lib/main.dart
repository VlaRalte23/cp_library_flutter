import 'package:flutter/material.dart';
import 'package:library_chawnpui/pages/dashboard.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'books.db');
  //   await deleteDatabase(path);
  //   debugPrint("OLD DATABASE DELETED");
  // }

  // final dbPath = await getDatabasesPath();
  // final path = join(dbPath, 'books.db');
  // debugPrint('Sqlite Database located at: $path');
  // await deleteOldDB();

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
