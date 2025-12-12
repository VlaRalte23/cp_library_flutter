import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/models/book.dart';
import 'package:library_chawnpui/models/book_issue.dart';
import 'package:library_chawnpui/models/member.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;

  const MemberDetailPage({super.key, required this.member});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  List<BookIssue> issuedList = [];
  Map<int, Book> bookMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadIssuedBooks();
  }

  Future<void> loadIssuedBooks() async {
    setState(() => loading = true);

    final issues = await BookDatabase.instance.getBooksIssuedTo(
      widget.member.id!,
    );
    final allBooks = await BookDatabase.instance.getBooks();
    bookMap = {for (var b in allBooks) b.id!: b};

    setState(() {
      issuedList = issues;
      loading = false;
    });
  }

  Future<void> _returnBook(BookIssue issue) async {
    await BookDatabase.instance.returnBook(issue.id!);
    await loadIssuedBooks();
  }

  Future<void> _extendDueDate(BookIssue issue) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: issue.dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      await BookDatabase.instance.extendDueDate(issue.id!, newDate);
      await loadIssuedBooks();
    }
  }

  // --- Issue dialog / action ---
  Future<void> _showIssueBookDialog(BuildContext ctx) async {
    List<Book> available = await BookDatabase.instance.getAvailableBooks();

    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No available books to issue.')),
      );
      return;
    }

    Book? selected;
    await showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Book to Issue'),
              content: SizedBox(
                width: double.maxFinite,
                child: DropdownButton<Book>(
                  isExpanded: true,
                  hint: const Text('Choose a book'),
                  value: selected,
                  items: available.map((b) {
                    final availText = '(${b.copies} copies)';
                    return DropdownMenuItem<Book>(
                      value: b,
                      child: Text('${b.name} — ${b.author} $availText'),
                    );
                  }).toList(),
                  onChanged: (b) => setState(() => selected = b),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () async {
                          final res = await BookDatabase.instance.issueBook(
                            selected!.id!,
                            widget.member.id!,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(res)));
                          }
                          Navigator.pop(context);
                          await loadIssuedBooks();
                        },
                  child: const Text('Issue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        onPressed: () => _showIssueBookDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Issue Book'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : issuedList.isEmpty
          ? const Center(
              child: Text(
                'No books issued',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: issuedList.length,
              itemBuilder: (context, index) {
                final issue = issuedList[index];
                final book = bookMap[issue.bookId];
                if (book == null) {
                  return const ListTile(title: Text('Book not found'));
                }

                final isOverdue = issue.dueDate.isBefore(DateTime.now());

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT SIDE (BOOK INFO)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Ziaktu: ${book.author}'),
                              Text(
                                'Issued: ${dateFormat.format(issue.issuedDate)}',
                              ),
                              Text(
                                'Due: ${dateFormat.format(issue.dueDate)}',
                                style: TextStyle(
                                  color: isOverdue ? Colors.red : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // RIGHT SIDE (BUTTONS)
                        Column(
                          children: [
                            TextButton(
                              onPressed: () => _returnBook(issue),
                              child: const Text(
                                'Return',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(height: 10),
                            IconButton(
                              icon: const Icon(Icons.date_range),
                              tooltip: 'Extend',
                              onPressed: () => _extendDueDate(issue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
