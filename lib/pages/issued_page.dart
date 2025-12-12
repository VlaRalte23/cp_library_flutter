import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/models/member.dart';

class IssuedPage extends StatefulWidget {
  const IssuedPage({super.key});

  @override
  State<IssuedPage> createState() => _IssuedPageState();
}

class _IssuedPageState extends State<IssuedPage> {
  late Future<List<Map<String, dynamic>>> _issuedFuture;

  @override
  void initState() {
    super.initState();
    _issuedFuture = BookDatabase.instance.getAllActiveIssues();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "Unknown";
    final date = DateTime.parse(dateStr);
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lehkhabu Hawhtute"),
        backgroundColor: Colors.lightBlue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _issuedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final issues = snapshot.data ?? [];

          if (issues.isEmpty) {
            return const Center(child: Text("No issued books."));
          }

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return FutureBuilder<Member?>(
                future: MemberDatabase.instance.getMemberById(
                  issue['memberId'],
                ),
                builder: (context, memberSnap) {
                  final member = memberSnap.data;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(
                        issue['bookName'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Author: ${issue['author']}"),
                          Text("Member: ${member?.name ?? 'Unknown'}"),
                          Text("Issued: ${formatDate(issue['issuedDate'])}"),
                          Text("Due: ${formatDate(issue['dueDate'])}"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
