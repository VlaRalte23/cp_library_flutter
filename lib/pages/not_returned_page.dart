import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';

class NotReturnedPage extends StatefulWidget {
  const NotReturnedPage({super.key});

  @override
  State<NotReturnedPage> createState() => _NotReturnedPageState();
}

class _NotReturnedPageState extends State<NotReturnedPage> {
  late Future<List<Map<String, dynamic>>> _overdueFuture;
  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  static const Color primaryColor = Color(0xFF313647);

  @override
  void initState() {
    super.initState();
    _loadOverdueBooks();
  }

  void _loadOverdueBooks() {
    setState(() {
      _overdueFuture = BookDatabase.instance.getOverdueBooks();
    });
  }

  List<Map<String, dynamic>> _filterOverdue(
    List<Map<String, dynamic>> overdue,
  ) {
    if (_searchQuery.isEmpty) return overdue;
    return overdue
        .where(
          (item) =>
              item['bookName'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item['author'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item['memberName'].toString().toLowerCase().contains(
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
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  int getDaysOverdue(String dueDateStr) {
    final dueDate = DateTime.parse(dueDateStr);
    final now = DateTime.now();
    return now.difference(dueDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header with Breadcrumbs
          Container(
            padding: const EdgeInsets.all(16),
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
                    Icon(Icons.home_outlined, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const Text(
                      'Overdue Books',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
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
              future: _overdueFuture,
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
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No overdue books!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _enrichOverdueWithMemberNames(snapshot.data!),
                  builder: (context, enrichedSnapshot) {
                    if (enrichedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final allOverdue = enrichedSnapshot.data ?? [];
                    final filteredOverdue = _filterOverdue(allOverdue);

                    if (filteredOverdue.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching overdue books',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final totalPages = (filteredOverdue.length / _rowsPerPage)
                        .ceil();
                    if (_currentPage >= totalPages && totalPages > 0) {
                      _currentPage = totalPages - 1;
                    }

                    final startIndex = _currentPage * _rowsPerPage;
                    final endIndex = (startIndex + _rowsPerPage).clamp(
                      0,
                      filteredOverdue.length,
                    );
                    final paginatedOverdue = filteredOverdue.sublist(
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
                                        _buildTableHeader('S.No', flex: 1),
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
                                        _buildTableHeader(
                                          'Days Overdue',
                                          flex: 1,
                                        ),
                                        _buildTableHeader('Actions', flex: 2),
                                      ],
                                    ),
                                  ),
                                  // Table Rows
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: paginatedOverdue.length,
                                    itemBuilder: (context, index) {
                                      final item = paginatedOverdue[index];
                                      final serialNumber =
                                          startIndex + index + 1;
                                      return _buildTableRow(item, serialNumber);
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
                                'Showing ${startIndex + 1}-$endIndex of ${filteredOverdue.length} overdue books',
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

  Future<List<Map<String, dynamic>>> _enrichOverdueWithMemberNames(
    List<Map<String, dynamic>> overdue,
  ) async {
    final enrichedOverdue = <Map<String, dynamic>>[];

    for (final item in overdue) {
      final member = await MemberDatabase.instance.getMemberById(
        item['memberId'],
      );
      enrichedOverdue.add({...item, 'memberName': member?.name ?? 'Unknown'});
    }

    return enrichedOverdue;
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

  Widget _buildTableRow(Map<String, dynamic> item, int serialNumber) {
    final daysOverdue = getDaysOverdue(item['dueDate']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
          left: BorderSide(color: Colors.red.shade700, width: 4),
        ),
      ),
      child: Row(
        children: [
          // Serial Number
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Text(
                  serialNumber.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          // Book Title
          Expanded(
            flex: 3,
            child: Text(
              item['bookName'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade900,
              ),
            ),
          ),
          // Author
          Expanded(
            flex: 2,
            child: Text(
              item['author'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Member
          Expanded(
            flex: 2,
            child: Text(
              item['memberName'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Issued Date
          Expanded(
            flex: 2,
            child: Text(
              formatDate(item['issuedDate']),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Due Date
          Expanded(
            flex: 2,
            child: Text(
              formatDate(item['dueDate']),
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Days Overdue
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$daysOverdue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade900,
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  color: primaryColor,
                  onPressed: () => _extendDueDate(item),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Extend Due Date',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  color: Colors.green.shade600,
                  onPressed: () => _returnBook(item),
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

  Future<void> _extendDueDate(Map<String, dynamic> item) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      await BookDatabase.instance.extendDueDate(item['issueId'], newDate);
      _loadOverdueBooks();
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

  Future<void> _returnBook(Map<String, dynamic> item) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Return Book',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        ),
        content: Text('Mark "${item['bookName']}" as returned?'),
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
      await BookDatabase.instance.returnBook(item['issueId']);
      _loadOverdueBooks();
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
