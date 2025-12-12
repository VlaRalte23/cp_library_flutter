import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/pages/book_page.dart';
import 'package:library_chawnpui/pages/member_page.dart';
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
  int issuedCount = 0;        // number of currently issued transactions
  int returnCount = 0;        // number of returned transactions
  int notReturnedCount = 0;   // number of overdue / not returned
  int memberCount = 0;

  final nowDate = DateTime.now();
  late final String formatDate;

  @override
  void initState() {
    super.initState();
    formatDate = DateFormat.yMMMMd().format(nowDate);
    _updateCounts();
  }

  /// Fetch counts based on NEW schema (book_issues table)
  Future<void> _updateCounts() async {
    final books = await BookDatabase.instance.getBooks();
    final members = await MemberDatabase.instance.getMembers();

    // Get counts from issues table
    final issued = await BookDatabase.instance.getActiveIssuedCount();       // returnDate IS NULL
    final returned = await BookDatabase.instance.getReturnedCount();         // returnDate IS NOT NULL
    final notReturned = await BookDatabase.instance.getNotReturnedCount();   // overdue or unreturned

    setState(() {
      bookCount = books.length;
      memberCount = members.length;

      issuedCount = issued;
      returnCount = returned;
      notReturnedCount = notReturned;
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
          ).then((_) => _updateCounts());
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
              "LEHKHABU",
              "$bookCount",
              Icons.book,
              Colors.blue,
              const BookPage(),
            ),
            _dashboardItem(
              "MEMBERS",
              "$memberCount",
              Icons.people,
              Colors.green,
              const MemberPage(),
            ),
            _dashboardItem(
              "LEHKHABU HAWHTU",
              "$issuedCount",
              Icons.local_shipping,
              Colors.lightBlue,
              const IssuedPage(),
            ),
            _dashboardItem(
              "RETURNED",
              "$returnCount",
              Icons.assignment_turned_in,
              Colors.redAccent,
              const ReturnedPage(),
            ),
            _dashboardItem(
              "NOT RETURNED",
              "$notReturnedCount",
              Icons.warning,
              Colors.orange,
              const NotReturnedPage(),
            ),
            dashboardCard(
              "TODAY",
              formatDate,
              Icons.calendar_today,
              Colors.deepPurple,
            ),
          ],
        );
      },
    );
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
            ListTile(
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Members"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MemberPage()),
                ).then((_) => _updateCounts());
              },
            ),
            ListTile(
              title: const Text("Books"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BookPage()),
                ).then((_) => _updateCounts());
              },
            ),
            ListTile(
              title: const Text("Issued"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const IssuedPage()),
                ).then((_) => _updateCounts());
              },
            ),
            ListTile(
              title: const Text("Returned"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReturnedPage()),
                ).then((_) => _updateCounts());
              },
            ),
            ListTile(
              title: const Text("Not Returned"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotReturnedPage()),
                ).then((_) => _updateCounts());
              },
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
