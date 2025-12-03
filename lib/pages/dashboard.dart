import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/pages/book_page.dart';
import 'package:library_chawnpui/pages/magazine_page.dart';
import 'package:library_chawnpui/pages/member_page.dart';
import 'package:library_chawnpui/pages/newspaper_page.dart';
import 'package:library_chawnpui/pages/issued_page.dart';
import 'package:library_chawnpui/pages/returned_page.dart';
import 'package:library_chawnpui/pages/not_returned_page.dart';
import 'package:library_chawnpui/widgets/dashboard_widget.dart';

class LibraryDashboardPage extends StatefulWidget {
  const LibraryDashboardPage({super.key});

  @override
  State<LibraryDashboardPage> createState() => _LibraryDashboardPageState();
}

class _LibraryDashboardPageState extends State<LibraryDashboardPage> {
  int bookCount = 0;
  int issuedCount = 0;
  int returnCount = 0;
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
    _updateCounts();
  }

  Future<void> _updateCounts() async {
    final books = await BookDatabase.instance.getBooks();
    final members = await MemberDatabase.instance.getMembers();

    setState(() {
      bookCount = books.length;
      issuedCount = books.where((b) => b.isIssued).length;
      returnCount = books.where((b) => !b.isIssued).length;
      memberCount = members.length;
    });
  }

  Widget _dashboardItem(
    String title,
    String value,
    IconData icon,
    Color color,
    Widget targetPage,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          ).then((_) => _updateCounts()); // 👈 Refresh counts after returning
        },
        child: dashboardCard(title, value, icon, color),
      ),
    );
  }

  Widget _buildDashboardBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxCardWidth = 180;
        int cardsPerRow = (constraints.maxWidth / maxCardWidth).floor();

        return GridView.count(
          crossAxisCount: cardsPerRow > 0 ? cardsPerRow : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          children: [
            _dashboardItem(
              "Books",
              "$bookCount",
              Icons.book,
              Colors.blue,
              const BookPage(),
            ),
            _dashboardItem(
              "Members",
              "$memberCount",
              Icons.people,
              Colors.green,
              const MemberPage(),
            ),
            // _dashboardItem(
            //   "NewsPapers",
            //   "1",
            //   Icons.newspaper,
            //   Colors.orange,
            //   const NewspaperPage(),
            // ),
            // _dashboardItem(
            //   "Magazines",
            //   "0",
            //   Icons.insert_drive_file,
            //   Colors.red,
            //   const MagazinePage(),
            // ),
            _dashboardItem(
              "ISSUED",
              "$issuedCount",
              Icons.flight,
              Colors.lightBlue,
              const IssuedPage(),
            ),
            _dashboardItem(
              "RETURNED",
              "$returnCount",
              Icons.thumb_up,
              Colors.redAccent,
              const ReturnedPage(),
            ),
            _dashboardItem(
              "NOT RETURNED",
              "1",
              Icons.thumb_down,
              Colors.green,
              const NotReturnedPage(),
            ),
            dashboardCard(
              "TODAY",
              formatDate,
              Icons.calendar_today,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  void _handleDrawerTap(BuildContext context, String title) {
    Navigator.pop(context); // Close drawer

    if (title == "Dashboard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LibraryDashboardPage()),
      );
    } else if (title == "Members") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MemberPage()),
      ).then((_) => _updateCounts()); // 👈 refresh counts
    } else if (title == "Books") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookPage()),
      ).then((_) => _updateCounts());
    } else if (title == "Magazines") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MagazinePage()),
      ).then((_) => _updateCounts());
    } else if (title == "Newspapers") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NewspaperPage()),
      ).then((_) => _updateCounts());
    } else if (title == "Issued") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const IssuedPage()),
      ).then((_) => _updateCounts());
    } else if (title == "Returned") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReturnedPage()),
      ).then((_) => _updateCounts());
    } else if (title == "Not Returned") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotReturnedPage()),
      ).then((_) => _updateCounts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.grey),
                  SizedBox(width: 10),
                  Text("Admin", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            ...menuItems.map(
              (item) => ListTile(
                leading: const Icon(Icons.chevron_right),
                title: Text(item),
                onTap: () => _handleDrawerTap(context, item),
              ),
            ),
          ],
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
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 197, 41, 41),
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 0, 0, 0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildDashboardBody(),
      bottomNavigationBar: const BottomAppBar(
        child: Center(
          child: Text('Chawnpui Branch YMA Literature sub-committee 2025'),
        ),
      ),
    );
  }
}
