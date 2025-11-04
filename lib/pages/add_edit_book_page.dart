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
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  bool _isIssued = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      // Populate fields if editing an existing book
      _idController.text = widget.book!.id.toString();
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _isIssued = widget.book!.isIssued;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final id = int.tryParse(_idController.text.trim());
      final title = _titleController.text.trim();
      final author = _authorController.text.trim();

      if (id == null) {
        _showSnackBar('Please enter a valid numeric ID.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final book = Book(
        id: id,
        title: title,
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
              // ✅ ID Field (manual entry)
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Book ID',
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

              // Author Field
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
