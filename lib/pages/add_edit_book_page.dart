// pages/add_edit_book_page.dart
import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/hive_services.dart';
import '../models/book.dart';

class AddEditBookPage extends StatefulWidget {
  final Book? book; // Null if adding a new book, otherwise editing existing

  const AddEditBookPage({super.key, this.book});

  @override
  State<AddEditBookPage> createState() => _AddEditBookPageState();
}

class _AddEditBookPageState extends State<AddEditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isIssued = false; // For the new 'isIssued' field
  final HiveService _hiveService = HiveService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      // Populate fields if editing an existing book
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _isIssued = widget.book!.isIssued;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final title = _titleController.text.trim();
      final author = _authorController.text.trim();

      // If editing, use the existing ID; otherwise, pass 0 and HiveService will generate a new one.
      final bookId = widget.book?.id ?? 0;

      final book = Book(
        id: bookId,
        title: title,
        author: author,
        isIssued: _isIssued,
      );

      try {
        if (widget.book == null) {
          // Add new book
          await _hiveService.addBook(book);
          _showSnackBar('Book added successfully!');
        } else {
          // Update existing book
          await _hiveService.updateBook(book);
          _showSnackBar('Book updated successfully!');
        }
        if (mounted) {
          Navigator.pop(context);
        }
        // Go back to BookPage
      } catch (e) {
        _showSnackBar('Failed to save book: $e', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add New Book' : 'Edit Book'),
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
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
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
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
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
              SwitchListTile(
                title: const Text('Is Issued?'),
                value: _isIssued,
                onChanged: (bool value) {
                  setState(() {
                    _isIssued = value;
                  });
                },
                secondary: const Icon(Icons.assignment),
              ),
              const SizedBox(height: 24),
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
                        widget.book == null ? 'Add Book' : 'Update Book',
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
