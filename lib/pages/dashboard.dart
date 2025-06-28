import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:library_chawnpui/models/book.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/widgets/dashboard_widget.dart';
import 'package:intl/intl.dart';

class LibraryDashboardPage extends StatefulWidget {
  const LibraryDashboardPage({super.key});

  @override
  State<LibraryDashboardPage> createState() => _LibraryDashboardPageState();
}

class _LibraryDashboardPageState extends State<LibraryDashboardPage> {
  int selectedIndex = 0;
  int bookCount = 0;
  int issuedCount = Hive.box<Book>(
    'books',
  ).values.where((b) => b.isIssued).length;
  int returnCount = Hive.box<Book>(
    'books',
  ).values.where((b) => !b.isIssued).length;
  int memberCount = 0;

  final nowDate = DateTime.now();
  late final String formatDate;

  final List<String> menuItems = [
    "Dashboard",
    "Members",
    "Books",
    "Magazines",
    "Newspapers",
    "Issued",
    "Returned",
    "Not Returned",
  ];

  @override
  void initState() {
    super.initState();
    formatDate = DateFormat.yMMMMd().format(nowDate);
    loadBookState();
  }

  void loadBookState() {
    final box = Hive.box<Book>('books');
    final books = box.values.toList();
    setState(() {
      bookCount = books.length;
      issuedCount = books.where((b) => b.isIssued).length;
    });
  }

  void loadMemberState() {
    final memberBox = Hive.box<Member>('member');
    final members = memberBox.values.toList();
    setState(() {
      memberCount = members.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        color: Colors.white,
        child: Drawer(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 50,
                      color: Color.fromARGB(255, 100, 98, 98),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Admin",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              ...menuItems.map(
                (title) => ListTile(
                  leading: const Icon(Icons.chevron_right),
                  title: Text(title),
                  selected: menuItems[selectedIndex] == title,
                  onTap: () {
                    setState(() => selectedIndex = menuItems.indexOf(title));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/yma.png', height: 40),
            const Text(
              " Chawnpui Branch YMA Library",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 197, 41, 41), // Blue
                Color.fromARGB(255, 255, 255, 255), // Light Blue
                Color.fromARGB(255, 0, 0, 0), // Cyan
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust the number of cards per row based on screen width
          double maxCardWidth = 180;
          int cardsPerRow = (constraints.maxWidth / maxCardWidth).floor();

          return GridView.count(
            crossAxisCount: cardsPerRow > 0 ? cardsPerRow : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            children: [
              dashboardCard("Books", "$bookCount", Icons.book, Colors.blue),
              dashboardCard(
                "Members",
                "$memberCount",
                Icons.people,
                Colors.green,
              ),
              dashboardCard("NewsPapers", "1", Icons.newspaper, Colors.orange),
              dashboardCard(
                "Magazines",
                "0",
                Icons.insert_drive_file,
                Colors.red,
              ),
              dashboardCard(
                "ISSUED",
                "$issuedCount",
                Icons.flight,
                Colors.lightBlue,
              ),
              dashboardCard("RETURNED", "1", Icons.thumb_up, Colors.redAccent),
              dashboardCard(
                "NOT RETURNED",
                "1",
                Icons.thumb_down,
                Colors.green,
              ),
              dashboardCard(
                "DATE TODAY",
                formatDate,
                Icons.calendar_today,
                Colors.orange,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Center(
          child: Text('Chawnpui Branch YMA Literature sub-committee 2025'),
        ),
      ),
    );
  }
}
