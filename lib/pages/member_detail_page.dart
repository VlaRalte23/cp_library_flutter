import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/models/book.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  Future<List<Book>>? _issuedBooks;

  @override
  void initState() {
    super.initState();
    _loadIssuedBooks();
  }

  // Example placeholder for issued books:
  void _loadIssuedBooks() {
    setState(() {
      _issuedBooks = BookDatabase.instance.getBooksIssuedTo(widget.member.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return Scaffold(
      appBar: AppBar(
        title: Text('${member.name} Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.green,
                  size: 40,
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${member.phone}'),
                    Text(
                      'Joined: ${member.joinedDate.toString().split(" ")[0]}',
                    ),
                    Text(
                      'Valid Till: ${member.validTill.toString().split(" ")[0]}',
                    ),
                    Text('Status: ${member.isActive ? "Active" : "Inactive"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Issued Books',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: _issuedBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No issued books yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final books = snapshot.data!;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isOverdue =
                          book.dueDate != null &&
                          book.dueDate!.isBefore(DateTime.now());
                      return Card(
                        color: isOverdue ? Colors.red.shade100 : Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.book,
                            color: isOverdue ? Colors.red : Colors.green,
                          ),
                          title: Text(
                            book.title,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author: ${book.author}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),

                              // New formatted due date
                              Text(
                                "Due: ${book.dueDate != null ? DateFormat('dd MMM yyyy').format(book.dueDate!) : 'No date'}",
                                style: TextStyle(
                                  color:
                                      (book.dueDate != null &&
                                          book.dueDate!.isBefore(
                                            DateTime.now(),
                                          ))
                                      ? Colors.red
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Extend Due Date button
                              TextButton(
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: book.dueDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      Duration(days: 365),
                                    ),
                                  );

                                  if (selectedDate != null) {
                                    await BookDatabase.instance.extendDueDate(
                                      book.id,
                                      selectedDate,
                                    );
                                    _loadIssuedBooks(); // refresh
                                    setState(() {});
                                  }
                                },
                                child: const Text("Extend Due Date"),
                              ),
                            ],
                          ),

                          trailing: SizedBox(
                            height: 70,
                            width: 100,
                            child: TextButton(
                              child: const Text(
                                'Return',
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () async {
                                await BookDatabase.instance.returnBook(book.id);
                                _loadIssuedBooks();
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Issue Book"),
        onPressed: () async {
          _showIssueBookDialog(context, member.id!);
        },
      ),
    );
  }

  void _showIssueBookDialog(BuildContext context, int memberId) async {
    final books = await BookDatabase.instance.getBooks();
    final availableBooks = books
        .where((book) => book.isIssued == false)
        .toList(); // only available books

    if (availableBooks.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No available books to issue.")),
        );
      }
      return;
    }

    Book? selectedBook;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Book to Issue"),
            content: SizedBox(
              width: double.maxFinite,
              child: DropdownButton<Book>(
                isExpanded: true,
                hint: const Text("Choose a book"),
                value: selectedBook,
                items: availableBooks.map((book) {
                  return DropdownMenuItem<Book>(
                    value: book,
                    child: Text("${book.title} - ${book.author}"),
                  );
                }).toList(),
                onChanged: (book) {
                  setState(() => selectedBook = book);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: selectedBook == null
                    ? null
                    : () async {
                        await BookDatabase.instance.issueBook(
                          selectedBook!.id,
                          memberId,
                        );
                        Navigator.pop(context);
                        _loadIssuedBooks();
                        setState(() {});
                      },
                child: const Text("Issue"),
              ),
            ],
          );
        },
      ),
    );
  }
}
