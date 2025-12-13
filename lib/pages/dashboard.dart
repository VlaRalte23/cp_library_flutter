import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:library_chawnpui/helper/book_database.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/models/book.dart';
import 'package:library_chawnpui/pages/book_page.dart';
import 'package:library_chawnpui/pages/member_page.dart';
import 'package:library_chawnpui/pages/issued_page.dart';
import 'package:library_chawnpui/pages/returned_page.dart';
import 'package:library_chawnpui/pages/not_returned_page.dart';

class LibraryDashboardPage extends StatefulWidget {
  const LibraryDashboardPage({super.key});

  @override
  State<LibraryDashboardPage> createState() => _LibraryDashboardPageState();
}

class _LibraryDashboardPageState extends State<LibraryDashboardPage> {
  int bookCount = 0;
  int issuedCount = 0;
  int returnCount = 0;
  int notReturnedCount = 0;
  int memberCount = 0;
  int selectedIndex = 0;
  List<Book> latestBooks = [];

  final nowDate = DateTime.now();
  late final String formatDate;

  static const Color primaryColor = Color(0xFF313647);
  static const Color cardColor = Color(0xFFF5F5F5);
  static const Color sidebarColor = Color(0xFF2A2D3A);

  @override
  void initState() {
    super.initState();
    formatDate = DateFormat.yMMMMd().format(nowDate);
    _updateCounts();
  }

  Future<void> _updateCounts() async {
    final books = await BookDatabase.instance.getBooks();
    final members = await MemberDatabase.instance.getMembers();
    final issued = await BookDatabase.instance.getActiveIssuedCount();
    final returned = await BookDatabase.instance.getReturnedCount();
    final notReturned = await BookDatabase.instance.getNotReturnedCount();

    // Get latest 5 books (sorted by ID descending)
    final sortedBooks = List<Book>.from(books)
      ..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    final latest = sortedBooks.take(5).toList();

    setState(() {
      bookCount = books.length;
      memberCount = members.length;
      issuedCount = issued;
      returnCount = returned;
      notReturnedCount = notReturned;
      latestBooks = latest;
    });
  }

  void _onSidebarItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    _updateCounts();
  }

  Widget _getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const BookPage();
      case 2:
        return const MemberPage();
      case 3:
        return const IssuedPage();
      case 4:
        return const ReturnedPage();
      case 5:
        return const NotReturnedPage();
      case 6:
        return _buildReportsContent();
      default:
        return _buildDashboardContent();
    }
  }

  String _getCurrentPageTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Library Management System';
      case 1:
        return 'Books Management';
      case 2:
        return 'Members Management';
      case 3:
        return 'Issued Books';
      case 4:
        return 'Returned Books';
      case 5:
        return 'Overdue Books';
      default:
        return 'Library Management System';
    }
  }

  Widget _buildSidebar(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 70 : 240,
      color: sidebarColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset('assets/yma.png', height: isSmallScreen ? 40 : 60),
                if (!isSmallScreen) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'YMA Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Chawnpui Branch',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  0,
                  Icons.dashboard_outlined,
                  'Dashboard',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(0),
                ),
                _buildSidebarItem(
                  1,
                  Icons.library_books_outlined,
                  'Books',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(1),
                ),
                _buildSidebarItem(
                  2,
                  Icons.people_outline,
                  'Members',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(2),
                ),
                _buildSidebarItem(
                  3,
                  Icons.send_outlined,
                  'Issued',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(3),
                ),
                _buildSidebarItem(
                  4,
                  Icons.assignment_turned_in_outlined,
                  'Returned',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(4),
                ),
                _buildSidebarItem(
                  5,
                  Icons.warning_amber_outlined,
                  'Overdue',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(5),
                ),
                const Divider(color: Colors.white24, height: 24),
                _buildSidebarItem(
                  6,
                  Icons.assessment_outlined,
                  'Reports',
                  isSmallScreen,
                  onTap: () => _onSidebarItemTap(6),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: isSmallScreen
                ? const Icon(Icons.admin_panel_settings, color: Colors.white70)
                : const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Admin',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String label,
    bool isSmallScreen, {
    VoidCallback? onTap,
  }) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSmallScreen
                ? Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 24,
                  )
                : Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _buildStatCard(
                    'Total Books',
                    '$bookCount',
                    Icons.library_books,
                    const Color(0xFF4A90E2),
                  ),
                  _buildStatCard(
                    'Total Members',
                    '$memberCount',
                    Icons.people,
                    const Color(0xFF50C878),
                  ),
                  _buildStatCard(
                    'Currently Issued',
                    '$issuedCount',
                    Icons.send,
                    const Color(0xFF9B59B6),
                  ),
                  _buildStatCard(
                    'Returned Books',
                    '$returnCount',
                    Icons.assignment_turned_in,
                    const Color(0xFF27AE60),
                  ),
                  _buildStatCard(
                    'Overdue Books',
                    '$notReturnedCount',
                    Icons.warning_amber,
                    const Color(0xFFE74C3C),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildBookStatusChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildIssueTrendChart()),
                ],
              ),
              const SizedBox(height: 32),
              _buildLatestBooksTable(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookStatusChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Status Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF4A90E2),
                    value: bookCount.toDouble(),
                    title: 'Total\n$bookCount',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF9B59B6),
                    value: issuedCount.toDouble(),
                    title: 'Issued\n$issuedCount',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFE74C3C),
                    value: notReturnedCount.toDouble(),
                    title: 'Overdue\n$notReturnedCount',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTrendChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Library Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    [
                      bookCount,
                      memberCount,
                      issuedCount,
                      returnCount,
                    ].reduce((a, b) => a > b ? a : b).toDouble() *
                    1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'Books',
                          'Members',
                          'Issued',
                          'Returned',
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: bookCount.toDouble(),
                        color: const Color(0xFF4A90E2),
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: memberCount.toDouble(),
                        color: const Color(0xFF50C878),
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: issuedCount.toDouble(),
                        color: const Color(0xFF9B59B6),
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: returnCount.toDouble(),
                        color: const Color(0xFF27AE60),
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
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

  Widget _buildLatestBooksTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Books Added',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          latestBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No books added yet',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                )
              : Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(0.8),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade50),
                      children: [
                        _buildTableHeader('ID'),
                        _buildTableHeader('Title'),
                        _buildTableHeader('Author'),
                        _buildTableHeader('Copies'),
                        _buildTableHeader('Available'),
                      ],
                    ),
                    ...latestBooks.map((book) {
                      final available = book.copies - book.issuedCount;
                      return TableRow(
                        children: [
                          _buildTableCell('${book.id}'),
                          _buildTableCell(book.name),
                          _buildTableCell(book.author),
                          _buildTableCell('${book.copies}'),
                          _buildTableCell(
                            '$available',
                            color: available > 0
                                ? const Color(0xFF27AE60)
                                : const Color(0xFFE74C3C),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color ?? Colors.grey.shade700,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: cardColor,
          body: Row(
            children: [
              _buildSidebar(isSmallScreen),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getCurrentPageTitle(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: primaryColor,
                            ),
                            onPressed: _updateCounts,
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _getCurrentPage()),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Chawnpui Branch YMA Literature sub-committee 2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsContent() {
    return _ReportsPage(onRefresh: _updateCounts);
  }
}

class _ReportsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const _ReportsPage({required this.onRefresh});

  @override
  State<_ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<_ReportsPage> {
  String _reportType = 'monthly'; // 'monthly' or 'yearly'
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF313647);

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    if (_reportType == 'monthly') {
      await _loadMonthlyReport();
    } else {
      await _loadYearlyReport();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadMonthlyReport() async {
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    final allIssues = await BookDatabase.instance.getAllActiveIssues();
    final allBooks = await BookDatabase.instance.getBooks();
    final allMembers = await MemberDatabase.instance.getMembers();

    // Filter issues for selected month
    final monthIssues = allIssues.where((issue) {
      final issueDate = DateTime.parse(issue['issuedDate']);
      return issueDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          issueDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final monthReturned = allIssues.where((issue) {
      if (issue['returnDate'] == null) return false;
      final returnDate = DateTime.parse(issue['returnDate']);
      return returnDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          returnDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final currentOverdue = allIssues.where((issue) {
      if (issue['returnDate'] != null) return false;
      final dueDate = DateTime.parse(issue['dueDate']);
      return dueDate.isBefore(DateTime.now());
    }).toList();

    setState(() {
      _reportData = {
        'totalBooks': allBooks.length,
        'totalMembers': allMembers.length,
        'booksIssued': monthIssues.length,
        'booksReturned': monthReturned.length,
        'currentlyIssued': allIssues
            .where((i) => i['returnDate'] == null)
            .length,
        'overdueBooks': currentOverdue.length,
        'newMembers': allMembers.where((m) {
          return m.joinedDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              m.joinedDate.isBefore(endDate.add(const Duration(days: 1)));
        }).length,
        'activeMembers': allMembers.where((m) {
          return m.validTill.isAfter(DateTime.now());
        }).length,
        'issuesByWeek': _groupIssuesByWeek(monthIssues, startDate, endDate),
        'topBooks': _getTopIssuedBooks(monthIssues),
        'topMembers': _getTopBorrowingMembers(monthIssues),
      };
    });
  }

  Future<void> _loadYearlyReport() async {
    final allIssues = await BookDatabase.instance.getAllActiveIssues();
    final allBooks = await BookDatabase.instance.getBooks();
    final allMembers = await MemberDatabase.instance.getMembers();

    // Filter issues for selected year
    final yearIssues = allIssues.where((issue) {
      final issueDate = DateTime.parse(issue['issuedDate']);
      return issueDate.year == _selectedDate.year;
    }).toList();

    final yearReturned = allIssues.where((issue) {
      if (issue['returnDate'] == null) return false;
      final returnDate = DateTime.parse(issue['returnDate']);
      return returnDate.year == _selectedDate.year;
    }).toList();

    final currentOverdue = allIssues.where((issue) {
      if (issue['returnDate'] != null) return false;
      final dueDate = DateTime.parse(issue['dueDate']);
      return dueDate.isBefore(DateTime.now());
    }).toList();

    setState(() {
      _reportData = {
        'totalBooks': allBooks.length,
        'totalMembers': allMembers.length,
        'booksIssued': yearIssues.length,
        'booksReturned': yearReturned.length,
        'currentlyIssued': allIssues
            .where((i) => i['returnDate'] == null)
            .length,
        'overdueBooks': currentOverdue.length,
        'newMembers': allMembers.where((m) {
          return m.joinedDate.year == _selectedDate.year;
        }).length,
        'activeMembers': allMembers.where((m) {
          return m.validTill.isAfter(DateTime.now());
        }).length,
        'issuesByMonth': _groupIssuesByMonth(yearIssues),
        'topBooks': _getTopIssuedBooks(yearIssues),
        'topMembers': _getTopBorrowingMembers(yearIssues),
      };
    });
  }

  Map<String, int> _groupIssuesByWeek(
    List<Map<String, dynamic>> issues,
    DateTime startDate,
    DateTime endDate,
  ) {
    final weeks = <String, int>{};
    int weekNum = 1;

    DateTime weekStart = startDate;
    while (weekStart.isBefore(endDate) || weekStart.isAtSameMomentAs(endDate)) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final count = issues.where((issue) {
        final issueDate = DateTime.parse(issue['issuedDate']);
        return issueDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            issueDate.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      weeks['Week $weekNum'] = count;
      weekNum++;
      weekStart = weekEnd.add(const Duration(days: 1));
    }

    return weeks;
  }

  Map<String, int> _groupIssuesByMonth(List<Map<String, dynamic>> issues) {
    final months = <String, int>{};
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (int i = 1; i <= 12; i++) {
      final count = issues.where((issue) {
        final issueDate = DateTime.parse(issue['issuedDate']);
        return issueDate.month == i;
      }).length;
      months[monthNames[i - 1]] = count;
    }

    return months;
  }

  List<Map<String, dynamic>> _getTopIssuedBooks(
    List<Map<String, dynamic>> issues,
  ) {
    final bookCounts = <int, int>{};
    final bookInfo = <int, Map<String, dynamic>>{};

    for (var issue in issues) {
      final bookId = issue['bookId'] as int;
      bookCounts[bookId] = (bookCounts[bookId] ?? 0) + 1;
      if (!bookInfo.containsKey(bookId)) {
        bookInfo[bookId] = {
          'name': issue['bookName'],
          'author': issue['author'],
        };
      }
    }

    final sorted = bookCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(5)
        .map(
          (e) => {
            'bookId': e.key,
            'name': bookInfo[e.key]!['name'],
            'author': bookInfo[e.key]!['author'],
            'count': e.value,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _getTopBorrowingMembers(
    List<Map<String, dynamic>> issues,
  ) {
    final memberCounts = <int, int>{};

    for (var issue in issues) {
      final memberId = issue['memberId'] as int;
      memberCounts[memberId] = (memberCounts[memberId] ?? 0) + 1;
    }

    final sorted = memberCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(5)
        .map((e) => {'memberId': e.key, 'count': e.value})
        .toList();
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Report Type Toggle
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton('Monthly', 'monthly'),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey.shade300,
                          ),
                          _buildToggleButton('Yearly', 'yearly'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Date Picker
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (_reportType == 'monthly') {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                            _loadReportData();
                          }
                        } else {
                          final year = await showDialog<int>(
                            context: context,
                            builder: (ctx) => _YearPickerDialog(
                              initialYear: _selectedDate.year,
                            ),
                          );
                          if (year != null) {
                            setState(
                              () => _selectedDate = DateTime(year, 1, 1),
                            );
                            _loadReportData();
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _reportType == 'monthly'
                            ? _formatMonth(_selectedDate)
                            : '${_selectedDate.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onRefresh();
                        _loadReportData();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_reportType == 'monthly' ? 'Monthly' : 'Yearly'} Report Summary',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                          children: [
                            _buildReportCard(
                              'Books Issued',
                              '${_reportData['booksIssued']}',
                              Icons.send,
                              Colors.blue.shade700,
                            ),
                            _buildReportCard(
                              'Books Returned',
                              '${_reportData['booksReturned']}',
                              Icons.assignment_turned_in,
                              Colors.green.shade700,
                            ),
                            _buildReportCard(
                              'Currently Issued',
                              '${_reportData['currentlyIssued']}',
                              Icons.library_books,
                              Colors.purple.shade700,
                            ),
                            _buildReportCard(
                              'Overdue Books',
                              '${_reportData['overdueBooks']}',
                              Icons.warning_amber,
                              Colors.red.shade700,
                            ),
                            _buildReportCard(
                              'Total Books',
                              '${_reportData['totalBooks']}',
                              Icons.menu_book,
                              Colors.indigo.shade700,
                            ),
                            _buildReportCard(
                              'Total Members',
                              '${_reportData['totalMembers']}',
                              Icons.people,
                              Colors.teal.shade700,
                            ),
                            _buildReportCard(
                              'New Members',
                              '${_reportData['newMembers']}',
                              Icons.person_add,
                              Colors.orange.shade700,
                            ),
                            _buildReportCard(
                              'Active Members',
                              '${_reportData['activeMembers']}',
                              Icons.check_circle,
                              Colors.green.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Charts
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildIssuesTrendChart()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTopBooksChart()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTopMembersTable(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    final isSelected = _reportType == value;
    return InkWell(
      onTap: () {
        setState(() => _reportType = value);
        _loadReportData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesTrendChart() {
    final data = _reportType == 'monthly'
        ? (_reportData['issuesByWeek'] as Map<String, int>)
        : (_reportData['issuesByMonth'] as Map<String, int>);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_reportType == 'monthly' ? 'Weekly' : 'Monthly'} Issue Trends',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (data.values.isEmpty
                            ? 0
                            : data.values.reduce((a, b) => a > b ? a : b))
                        .toDouble() +
                    5,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = data.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.entries.toList().asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: primaryColor,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBooksChart() {
    final topBooks = _reportData['topBooks'] as List<Map<String, dynamic>>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Issued Books',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (topBooks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...topBooks.asMap().entries.map((entry) {
              final index = entry.key;
              final book = entry.value;
              final colors = [
                Colors.amber.shade700,
                Colors.grey.shade600,
                Colors.brown.shade600,
                Colors.blue.shade600,
                Colors.green.shade600,
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors[index],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['name'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            book['author'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${book['count']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors[index],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopMembersTable() {
    final topMembers = _reportData['topMembers'] as List<Map<String, dynamic>>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Borrowing Members',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (topMembers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _enrichMembersData(topMembers),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                final enrichedMembers = snapshot.data ?? [];
                return Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      children: [
                        _buildTableHeader('Rank'),
                        _buildTableHeader('ID'),
                        _buildTableHeader('Name'),
                        _buildTableHeader('Section'),
                        _buildTableHeader('Books'),
                      ],
                    ),
                    ...enrichedMembers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell('${member['memberId']}'),
                          _buildTableCell(member['name'] ?? 'Unknown'),
                          _buildTableCell(member['section'] ?? '-'),
                          _buildTableCell(
                            '${member['count']}',
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _enrichMembersData(
    List<Map<String, dynamic>> topMembers,
  ) async {
    final enriched = <Map<String, dynamic>>[];

    for (var item in topMembers) {
      final member = await MemberDatabase.instance.getMemberById(
        item['memberId'],
      );
      enriched.add({
        ...item,
        'name': member?.name ?? 'Unknown',
        'section': member?.section ?? '-',
      });
    }

    return enriched;
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {FontWeight? fontWeight, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: fontWeight,
          color: color ?? Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _YearPickerDialog extends StatelessWidget {
  final int initialYear;

  const _YearPickerDialog({required this.initialYear});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 2019, (i) => 2020 + i);

    return AlertDialog(
      title: const Text('Select Year'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[years.length - 1 - index];
            return ListTile(
              title: Text(year.toString()),
              selected: year == initialYear,
              onTap: () => Navigator.pop(context, year),
            );
          },
        ),
      ),
    );
  }
}
