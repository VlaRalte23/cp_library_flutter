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
}
