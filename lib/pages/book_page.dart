// import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import '../models/book.dart';
import 'add_edit_book_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late Future<List<Book>> _booksFuture;
  String _searchQuery = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _booksFuture = BookDatabase.instance.getBooks();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    // final db = await BookDatabase.instance.database;
    // final rows = await db.rawQuery("SELECT * FROM books");
    // print('BOOKS TABLE ROWS:');
    // print(rows);
    _booksFuture = BookDatabase.instance.getBooks();
    // final books = await _booksFuture;
    // log(books.map((e) => e.toMap()).toList().toString());
  }

  void _applyFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  List<Book> _filterBooks(List<Book> books) {
    List<Book> filtered = books;
    if (_filter == 'Issued') {
      filtered = filtered.where((b) => b.isIssued).toList();
    } else if (_filter == 'Available') {
      filtered = filtered.where((b) => !b.isIssued).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (b) =>
                b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                b.author.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lehkhabu List',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Buttons +  Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Issued'),
                    _buildFilterChip('Available'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditBookPage(),
                      ),
                    );
                    setState(() {
                      _loadBooks();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📚 Book List
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading books: ${snapshot.error}'),
                  );
                }

                final books = _filterBooks(snapshot.data ?? []);

                if (books.isEmpty) {
                  return const Center(child: Text('No books found.'));
                }

                books.sort((a, b) => a.id.compareTo(b.id));

                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
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
                              'ID: ${book.id}',
                              style: const TextStyle(fontSize: 14),
                            ),
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
                                setState(() {
                                  _loadBooks();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, book.id),
                            ),
                          ],
                        ),
                        onTap: () => _showBookDetails(context, book),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue,
      onSelected: (_) => _applyFilter(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await BookDatabase.instance.deleteBook(bookId);
                  if (context.mounted) {
                    _showSnackBar(context, 'Book deleted successfully!');
                    setState(() => _loadBooks());
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
              onPressed: () => Navigator.of(dialogContext).pop(),
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
