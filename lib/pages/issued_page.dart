import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';

class IssuedPage extends StatefulWidget {
  const IssuedPage({super.key});

  @override
  State<IssuedPage> createState() => _IssuedPageState();
}

class _IssuedPageState extends State<IssuedPage> {
  late Future<List<Map<String, dynamic>>> _issuedFuture;
  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  static const Color primaryColor = Color(0xFF313647);

  @override
  void initState() {
    super.initState();
    _loadIssuedBooks();
  }

  void _loadIssuedBooks() {
    setState(() {
      _issuedFuture = BookDatabase.instance.getAllActiveIssues();
    });
  }

  List<Map<String, dynamic>> _filterIssues(List<Map<String, dynamic>> issues) {
    if (_searchQuery.isEmpty) return issues;
    return issues
        .where(
          (issue) =>
              issue['bookName'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              issue['author'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              issue['memberName'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
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
                      'Issued Books',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by book, author, or member...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 0;
                    });
                  },
                ),
              ],
            ),
          ),
          // Table Content
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _issuedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final issues = snapshot.data ?? [];

                // Fetch member names and add to issues
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _enrichIssuesWithMemberNames(issues),
                  builder: (context, enrichedSnapshot) {
                    if (enrichedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final enrichedIssues = enrichedSnapshot.data ?? [];

                    // Sort by issued date descending (latest first)
                    enrichedIssues.sort((a, b) {
                      final dateA = DateTime.parse(a['issuedDate']);
                      final dateB = DateTime.parse(b['issuedDate']);
                      return dateB.compareTo(dateA);
                    });

                    final filteredIssues = _filterIssues(enrichedIssues);

                    if (filteredIssues.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No issued books'
                                  : 'No matching issued books',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final totalPages = (filteredIssues.length / _rowsPerPage)
                        .ceil();
                    if (_currentPage >= totalPages && totalPages > 0) {
                      _currentPage = totalPages - 1;
                    }

                    final startIndex = _currentPage * _rowsPerPage;
                    final endIndex = (startIndex + _rowsPerPage).clamp(
                      0,
                      filteredIssues.length,
                    );
                    final paginatedIssues = filteredIssues.sublist(
                      startIndex,
                      endIndex,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  // Table Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTableHeader(
                                          'Book Title',
                                          flex: 3,
                                        ),
                                        _buildTableHeader('Author', flex: 2),
                                        _buildTableHeader('Member', flex: 2),
                                        _buildTableHeader(
                                          'Issued Date',
                                          flex: 2,
                                        ),
                                        _buildTableHeader('Due Date', flex: 2),
                                        _buildTableHeader('Status', flex: 1),
                                        _buildTableHeader('Actions', flex: 1),
                                      ],
                                    ),
                                  ),
                                  // Table Rows
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: paginatedIssues.length,
                                    itemBuilder: (context, index) {
                                      final issue = paginatedIssues[index];
                                      return _buildTableRow(issue, index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Pagination Controls
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Showing ${startIndex + 1}-$endIndex of ${filteredIssues.length} issued books',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Rows per page:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: _rowsPerPage,
                                  underline: const SizedBox(),
                                  items: [5, 10, 20, 50].map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _rowsPerPage = newValue!;
                                      _currentPage = 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 0
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                                color: primaryColor,
                                disabledColor: Colors.grey.shade300,
                              ),
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages - 1
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                      }
                                    : null,
                                color: primaryColor,
                                disabledColor: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<List<Map<String, dynamic>>> _enrichIssuesWithMemberNames(
    List<Map<String, dynamic>> issues,
  ) async {
    final enrichedIssues = <Map<String, dynamic>>[];

    for (final issue in issues) {
      final member = await MemberDatabase.instance.getMemberById(
        issue['memberId'],
      );
      enrichedIssues.add({...issue, 'memberName': member?.name ?? 'Unknown'});
    }

    return enrichedIssues;
  }

  Widget _buildTableHeader(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> issue, int index) {
    final dueDate = DateTime.parse(issue['dueDate']);
    final isOverdue = dueDate.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade50 : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
          left: isOverdue
              ? BorderSide(color: Colors.red.shade700, width: 4)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          // Overdue Indicator
          if (isOverdue)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade700,
                size: 20,
              ),
            ),
          // Book Title
          Expanded(
            flex: 3,
            child: Text(
              issue['bookName'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isOverdue ? Colors.red.shade900 : primaryColor,
              ),
            ),
          ),
          // Author
          Expanded(
            flex: 2,
            child: Text(
              issue['author'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Member
          Expanded(
            flex: 2,
            child: Text(
              issue['memberName'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Issued Date
          Expanded(
            flex: 2,
            child: Text(
              formatDate(issue['issuedDate']),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Due Date
          Expanded(
            flex: 2,
            child: Text(
              formatDate(issue['dueDate']),
              style: TextStyle(
                fontSize: 13,
                color: isOverdue ? Colors.red.shade700 : Colors.grey.shade700,
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isOverdue ? 'Overdue' : 'Active',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOverdue
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  color: primaryColor,
                  onPressed: () => _extendDueDate(issue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Extend Due Date',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  color: Colors.green.shade600,
                  onPressed: () => _returnBook(issue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Return Book',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _extendDueDate(Map<String, dynamic> issue) async {
    final currentDueDate = DateTime.parse(issue['dueDate']);
    final newDate = await showDatePicker(
      context: context,
      initialDate: currentDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      await BookDatabase.instance.extendDueDate(issue['issueId'], newDate);
      _loadIssuedBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Due date extended successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _returnBook(Map<String, dynamic> issue) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Return Book',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        ),
        content: Text('Mark "${issue['bookName']}" as returned?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BookDatabase.instance.returnBook(issue['issueId']);
      _loadIssuedBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book returned successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
