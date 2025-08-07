// pages/book_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import for ValueListenableBuilder
import 'package:library_chawnpui/helper/hive_services.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';
import '../models/book.dart';
import 'add_edit_book_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final HiveService _hiveService = HiveService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: ValueListenableBuilder<Box<Book>>(
        valueListenable: _hiveService
            .getBooksListenable(), // Listen to changes in the books box
        builder: (context, box, _) {
          final books = box.values.toList(); // Get all books from the box
          // Sort books by ID for consistent display
          books.sort((a, b) => a.id.compareTo(b.id));

          if (books.isEmpty) {
            return const Center(child: Text('No books found. Add Books'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Author: ${book.author}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Year: ${book.id}',
                        style: const TextStyle(fontSize: 14),
                      ), // Using ID as a placeholder for year
                      Text(
                        'Issued: ${book.isIssued ? 'Yes' : 'No'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditBookPage(book: book),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, book.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showBookDetails(context, book);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBookPage()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int bookId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                try {
                  await _hiveService.deleteBook(bookId);
                  if (context.mounted) {
                    _showSnackBar(context, 'Book deleted successfully!');
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showSnackBar(
                      context,
                      'Failed to delete book: $e',
                      isError: true,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(book.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Author: ${book.author}'),
                Text('ID: ${book.id}'),
                Text('Issued: ${book.isIssued ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
