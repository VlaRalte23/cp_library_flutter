import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/models/book.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class BulkUploadPage extends StatefulWidget {
  const BulkUploadPage({super.key});

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  static const Color primaryColor = Color(0xFF313647);

  String? _selectedBookFile;
  String? _selectedBookContent; // Store file content
  String? _selectedMemberFile;
  bool _isUploadingBooks = false;
  String? _uploadStatus;
  int _totalRecords = 0;
  int _successRecords = 0;
  int _failedRecords = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    Text(
                      'Bulk Upload',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bulk Data Upload',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload CSV files to add multiple books or members at once',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  // Upload Cards
                  Row(
                    children: [
                      Expanded(child: _buildUploadCard('Books')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildUploadCard('Members')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String type) {
    final isBooks = type == 'Books';
    final icon = isBooks ? Icons.library_books : Icons.people;
    final color = isBooks ? Colors.blue.shade700 : Colors.green.shade700;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'Upload $type',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Upload Area
          InkWell(
            onTap: isBooks ? _pickBookFile : null, // Members later
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      (isBooks && _selectedBookFile != null) ||
                          (!isBooks && _selectedMemberFile != null)
                      ? color
                      : Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((isBooks && _selectedBookFile == null) ||
                        (!isBooks && _selectedMemberFile == null)) ...[
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Click to upload CSV file',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'or drag and drop',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.check_circle, size: 48, color: color),
                      const SizedBox(height: 16),
                      Text(
                        'File Selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          isBooks
                              ? _selectedBookFile ?? ''
                              : _selectedMemberFile ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CSV Format Requirements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isBooks)
                  Text(
                    'Required columns: ID, SERIAL NO, BOOK TITLE, AUTHOR, NO OF COPIES, BOOK SHELF LOCATION\n\nThe CSV should have headers. ID will be the book ID in the database.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    'Columns: name, phone, section, joinedDate, validTill\nExample: "John Doe","1234567890","YMA","2025-01-01","2026-01-01"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBooks
                      ? _downloadBookTemplate
                      : null, // Members later
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download Template'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isBooks
                      ? (_selectedBookFile != null && !_isUploadingBooks
                            ? _uploadBooks
                            : null)
                      : null, // Members later
                  icon: _isUploadingBooks && isBooks
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload, size: 18),
                  label: Text(
                    _isUploadingBooks && isBooks
                        ? 'Uploading...'
                        : 'Upload File',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          // Upload Status
          if (isBooks && _uploadStatus != null && !_isUploadingBooks) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _failedRecords > 0
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _failedRecords > 0
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _failedRecords > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle,
                        size: 20,
                        color: _failedRecords > 0
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _uploadStatus!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _failedRecords > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_totalRecords > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Total: $_totalRecords | Success: $_successRecords | Failed: $_failedRecords',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // File picker for books CSV
  Future<void> _pickBookFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Read file data directly instead of path
      );

      if (result != null && result.files.single.bytes != null) {
        // Store the file data as string
        final bytes = result.files.single.bytes!;
        final content = String.fromCharCodes(bytes);

        setState(() {
          _selectedBookFile = result.files.single.name;
          _selectedBookContent = content;
          _uploadStatus = null;
          _totalRecords = 0;
          _successRecords = 0;
          _failedRecords = 0;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking file: $e');
    }
  }

  // Download book CSV template
  Future<void> _downloadBookTemplate() async {
    try {
      // Load the template from assets
      final csvData = await rootBundle.loadString('assets/books_template.csv');

      // Get the downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorDialog('Could not access Downloads folder');
        return;
      }

      // Create file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/books_template_$timestamp.csv';
      final file = File(filePath);

      // Write the template content
      await file.writeAsString(csvData);

      // Show success message
      _showSuccessDialog(
        'Template downloaded successfully!\n\nSaved to:\n$filePath',
      );
    } catch (e) {
      _showErrorDialog('Error downloading template: $e');
    }
  }

  // Upload and process books CSV
  Future<void> _uploadBooks() async {
    if (_selectedBookContent == null) return;

    setState(() {
      _isUploadingBooks = true;
      _uploadStatus = null;
      _totalRecords = 0;
      _successRecords = 0;
      _failedRecords = 0;
    });

    try {
      final lines = _selectedBookContent!.split('\n');

      // Skip header row
      final dataLines = lines
          .skip(1)
          .where((line) => line.trim().isNotEmpty)
          .toList();

      setState(() {
        _totalRecords = dataLines.length;
      });

      for (var line in dataLines) {
        try {
          // Parse CSV line (handle quoted values)
          final values = _parseCSVLine(line);

          if (values.length < 6) {
            _failedRecords++;
            continue;
          }

          // Map CSV columns to Book model
          // CSV: SI. No (ID), SERIAL NO. (BOOK ID), LEHKHABU HMING (BOOK TITLE),
          //      ZIAKTU (AUTHOR), COPY NEIH ZAT (NO OF COPIES), AWMNA (BOOKSHELF)

          final id = int.tryParse(values[0].trim());
          final title = values[2].trim();
          final author = values[3].trim();
          final copies = int.tryParse(values[4].trim()) ?? 0;
          final bookshelf = values[5].trim();

          if (id == null || title.isEmpty || author.isEmpty) {
            _failedRecords++;
            continue;
          }

          // Create book object
          final book = Book(
            id: id,
            name: title,
            author: author,
            bookshelf: bookshelf,
            copies: copies,
            issuedCount: 0,
          );

          // Insert into database
          await BookDatabase.instance.insertBook(book);
          _successRecords++;
        } catch (e) {
          _failedRecords++;
        }
      }

      setState(() {
        _isUploadingBooks = false;
        if (_failedRecords == 0) {
          _uploadStatus = 'All books uploaded successfully!';
        } else {
          _uploadStatus = 'Upload completed with some errors';
        }
        _selectedBookFile = null;
        _selectedBookContent = null;
      });

      if (_successRecords > 0) {
        _showSuccessDialog(
          'Books uploaded successfully!\n\n'
          'Total: $_totalRecords\n'
          'Success: $_successRecords\n'
          'Failed: $_failedRecords',
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingBooks = false;
        _uploadStatus = 'Upload failed: $e';
      });
      _showErrorDialog('Error uploading books: $e');
    }
  }

  // Parse CSV line handling quoted values
  List<String> _parseCSVLine(String line) {
    List<String> result = [];
    StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }

    result.add(current.toString());
    return result;
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
