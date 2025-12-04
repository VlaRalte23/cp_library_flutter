import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import '../models/book.dart';

class AddEditBookPage extends StatefulWidget {
  final Book? book; // Null if adding a new book, otherwise editing existing

  const AddEditBookPage({super.key, this.book});

  @override
  State<AddEditBookPage> createState() => _AddEditBookPageState();
}

class _AddEditBookPageState extends State<AddEditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _bookNameController = TextEditingController();
  final _bookShelfController = TextEditingController();
  final _bookCopiesController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isIssued = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _idController.text = widget.book!.id.toString();
      _bookNameController.text = widget.book!.name;
      _authorController.text = widget.book!.author;
      _bookShelfController.text = widget.book!.bookshelf; // FIXED
      _bookCopiesController.text = widget.book!.copies.toString();
      _isIssued = widget.book!.isIssued;
    }
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
  void dispose() {
    _idController.dispose();
    _bookNameController.dispose();
    _authorController.dispose();
    _bookShelfController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final id = int.tryParse(_idController.text.trim());
      final bookName = _bookNameController.text.trim();
      final bookCopies = int.tryParse(_bookCopiesController.text.trim()) ?? 0;
      final bookShelf = _bookShelfController.text.trim();
      final author = _authorController.text.trim();

      if (id == null) {
        _showSnackBar('Please enter a valid numeric ID.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final book = Book(
        id: id,
        name: bookName,
        bookshelf: bookShelf,
        copies: bookCopies,
        author: author,
        isIssued: _isIssued,
      );

      try {
        final db = BookDatabase.instance;

        if (widget.book == null) {
          // Add new book
          await db.insertBook(book);
          _showSnackBar('Book added successfully!');
        } else {
          // Update existing book
          await db.updateBook(book);
          _showSnackBar('Book updated successfully!');
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to save book: $e', isError: true);
        log('Faild to update $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // ID manual entry tihna
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Lehkhabu Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a book ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Book ID must be a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                  labelText: 'Lehkhabu Hming',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Author Field
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'A Ziaktu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookCopiesController,
                decoration: InputDecoration(
                  labelText: 'Lehkhabu Neih Zat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Number of Copy';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookShelfController,
                decoration: InputDecoration(
                  labelText: 'Lehkhabu Awmna',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.shelves),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Book Shelf';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Is Issued Switch
              SwitchListTile(
                title: const Text('Is Issued?'),
                value: _isIssued,
                onChanged: (value) => setState(() => _isIssued = value),
                secondary: const Icon(Icons.assignment),
              ),
              const SizedBox(height: 24),

              // Save Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditing ? 'Update Book' : 'Add Book',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
