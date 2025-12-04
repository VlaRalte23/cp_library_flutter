import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/models/book.dart';

class IssuedPage extends StatefulWidget {
  const IssuedPage({super.key});

  @override
  State<IssuedPage> createState() => _IssuedPageState();
}

class _IssuedPageState extends State<IssuedPage> {
  late Future<List<Book>> _issuedBooksFuture;

  @override
  void initState() {
    super.initState();
    _issuedBooksFuture = BookDatabase.instance.getIssuedBooks();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Unknown";

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

    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month - 1];
    String year = date.year.toString();

    return "$day $month $year"; // example: 05 Jan 2025
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
        backgroundColor: Colors.lightBlue,
      ),
      body: FutureBuilder<List<Book>>(
        future: _issuedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final issuedBooks = snapshot.data ?? [];

          if (issuedBooks.isEmpty) {
            return const Center(child: Text("No issued books yet."));
          }

          return ListView.builder(
            itemCount: issuedBooks.length,
            itemBuilder: (context, index) {
              final book = issuedBooks[index];

              return FutureBuilder<Map<String, dynamic>?>(
                future: book.issuedTo != null
                    ? BookDatabase.instance.getMemberById(book.issuedTo!)
                    : Future.value(null),
                builder: (context, memberSnap) {
                  String memberName = "Unknown Member";

                  if (memberSnap.hasData && memberSnap.data != null) {
                    memberName = memberSnap.data!['name'] ?? "Member";
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(
                        book.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Author: ${book.author}"),
                          Text("Bookshelf: ${book.bookshelf}"),
                          Text("Issued To: $memberName (ID: ${book.issuedTo})"),
                          if (book.issuedDate != null)
                            Text("Issued Date: ${formatDate(book.issuedDate)}"),
                          if (book.dueDate != null)
                            Text("Due Date: ${formatDate(book.dueDate)}"),
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
