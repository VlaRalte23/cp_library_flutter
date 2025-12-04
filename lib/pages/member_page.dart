import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/pages/member_detail_page.dart';
import 'package:library_chawnpui/widgets/add_member_dialog.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late Future<List<Member>> _membersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();

    // Listen to search input
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadMembers() {
    _membersFuture = MemberDatabase.instance.getMembers();
  }

  void _refreshMembers() {
    setState(() {
      _loadMembers();
    });
  }

  List<Member> _filterMembers(List<Member> members) {
    if (_searchQuery.isEmpty) return members;
    return members
        .where(
          (m) =>
              m.name.toLowerCase().contains(_searchQuery) ||
              m.phone.toLowerCase().contains(_searchQuery),
        )
        .toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Member List',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Search field + Add Member button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Add Member button full width
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Member',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final added = await showDialog(
                      context: context,
                      builder: (_) => const AddMemberDialog(),
                    );
                    if (added == true) _refreshMembers();
                  },
                ),
              ],
            ),
          ),

          // Members list
          Expanded(
            child: FutureBuilder<List<Member>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final members = snapshot.data ?? [];
                final filteredMembers = _filterMembers(members);

                if (filteredMembers.isEmpty) {
                  return const Center(child: Text('No members found'));
                }

                final activeMembers = filteredMembers
                    .where((m) => m.isActive)
                    .toList();
                final nonActiveMembers = filteredMembers
                    .where((m) => !m.isActive)
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async => _refreshMembers(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Active Members',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMemberList(activeMembers, isActive: true),
                      const SizedBox(height: 16),
                      const Text(
                        'Non-Active Members',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMemberList(nonActiveMembers, isActive: false),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(List<Member> members, {required bool isActive}) {
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          isActive ? 'No active Members.' : 'No non-active Members',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: members.map((member) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Icon(
              isActive ? Icons.person : Icons.person_off,
              color: isActive ? Colors.green : Colors.red,
            ),
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone: ${member.phone}'),
                Text(
                  'Valid Till: ${formatDate(member.validTill)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 59, 59, 59),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Member'),
                    content: const Text(
                      'Are you sure you want to delete this member?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (!mounted) return;

                if (confirm == true) {
                  try {
                    if (member.id != null) {
                      await MemberDatabase.instance.deleteMember(member.id!);
                      if (!mounted) return;
                      _refreshMembers();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Member Deleted')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to Delete: missing id'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete Failed: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
            onTap: () async {
              final updated = await Navigator.of(
                context,
              ).push(_createSlideUpRoute(member));

              if (updated == true) {
                _refreshMembers(); // <— reload UI
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Route _createSlideUpRoute(Member member) {
    return PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) =>
          MemberDetailPage(member: member),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween(begin: begin, end: end).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
