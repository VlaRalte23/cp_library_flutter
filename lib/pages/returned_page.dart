import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';

class ReturnedPage extends StatefulWidget {
  const ReturnedPage({super.key});

  @override
  State<ReturnedPage> createState() => _ReturnedPageState();
}

class _ReturnedPageState extends State<ReturnedPage> {
  late Future<List<Map<String, dynamic>>> _returnedFuture;
  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  static const Color primaryColor = Color(0xFF313647);

  @override
  void initState() {
    super.initState();
    _loadReturnedBooks();
  }

  void _loadReturnedBooks() {
    setState(() {
      _returnedFuture = BookDatabase.instance.getReturnedBooks();
    });
  }

  List<Map<String, dynamic>> _filterReturned(
    List<Map<String, dynamic>> returned,
  ) {
    if (_searchQuery.isEmpty) return returned;
    return returned
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
                      'Returned Books',
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
              future: _returnedFuture,
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
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No returned books yet',
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
                  future: _enrichReturnedWithMemberNames(snapshot.data!),
                  builder: (context, enrichedSnapshot) {
                    if (enrichedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final allReturned = enrichedSnapshot.data ?? [];
                    final filteredReturned = _filterReturned(allReturned);

                    if (filteredReturned.isEmpty) {
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
                              'No matching returned books',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final totalPages = (filteredReturned.length / _rowsPerPage)
                        .ceil();
                    if (_currentPage >= totalPages && totalPages > 0) {
                      _currentPage = totalPages - 1;
                    }

                    final startIndex = _currentPage * _rowsPerPage;
                    final endIndex = (startIndex + _rowsPerPage).clamp(
                      0,
                      filteredReturned.length,
                    );
                    final paginatedReturned = filteredReturned.sublist(
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
                                          'Returned Date',
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Table Rows
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: paginatedReturned.length,
                                    itemBuilder: (context, index) {
                                      final item = paginatedReturned[index];
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
                                'Showing ${startIndex + 1}-$endIndex of ${filteredReturned.length} returned books',
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

  Future<List<Map<String, dynamic>>> _enrichReturnedWithMemberNames(
    List<Map<String, dynamic>> returned,
  ) async {
    final enrichedReturned = <Map<String, dynamic>>[];

    for (final item in returned) {
      final member = await MemberDatabase.instance.getMemberById(
        item['memberId'],
      );
      enrichedReturned.add({...item, 'memberName': member?.name ?? 'Unknown'});
    }

    return enrichedReturned;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
          left: BorderSide(color: Colors.green.shade700, width: 4),
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
                    Icons.check_circle,
                    color: Colors.green.shade700,
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
                color: Colors.green.shade900,
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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          // Returned Date
          Expanded(
            flex: 2,
            child: Text(
              formatDate(item['returnDate']),
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
