import 'package:flutter/material.dart';
import 'package:library_chawnpui/pages/book_page.dart';
import 'package:library_chawnpui/pages/dashboard.dart';
import 'package:library_chawnpui/pages/magazine_page.dart';
import 'package:library_chawnpui/pages/member_page.dart';
import 'package:library_chawnpui/pages/newspaper_page.dart';
import 'package:library_chawnpui/pages/issued_page.dart';
import 'package:library_chawnpui/pages/returned_page.dart';
import 'package:library_chawnpui/pages/not_returned_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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

    void handleNavigation(String title) {
      Navigator.pop(context); // Close the drawer

      Widget? page;
      switch (title) {
        case "Dashboard":
          page = const LibraryDashboardPage();
          break;
        case "Members":
          page = const MemberPage();
          break;
        case "Books":
          page = const BookPage();
          break;
        case "Magazines":
          page = const MagazinePage();
          break;
        case "Newspapers":
          page = const NewspaperPage();
          break;
        case "Issued":
          page = const IssuedPage();
          break;
        case "Returned":
          page = const ReturnedPage();
          break;
        case "Not Returned":
          page = const NotReturnedPage();
          break;
      }

      if (page != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page!),
        );
      }
    }

    return Drawer(
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
              onTap: () => handleNavigation(item),
            ),
          ),
        ],
      ),
    );
  }
}
