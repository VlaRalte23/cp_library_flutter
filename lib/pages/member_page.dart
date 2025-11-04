import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/widgets/add_member_dialog.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    _membersFuture = MemberDatabase.instance.getMembers();
  }

  void _refreshMembers() {
    setState(() {
      _loadMembers();
    });
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<List<Member>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return const Center(child: Text('No members added yet'));
          }
          final activeMembers = members.where((m) => m.isActive).toList();
          final nonActiveMembers = members.where((m) => !m.isActive).toList();

          return RefreshIndicator(
            onRefresh: () async => _refreshMembers(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      label: const Text(
                        'Add Member',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final added = await showDialog(
                          context: context,
                          builder: (_) => const AddMemberDialog(),
                        );
                        if (added == true) {
                          _refreshMembers();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  const Text(
                    'Active Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildMemberList(activeMembers, isActive: true),
                  const SizedBox(height: 16),
                  const Text(
                    'Non-Active Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildMemberList(nonActiveMembers, isActive: false),
                ],
              ),
            ),
          );
        },
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
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
                  'Valid Till: ${member.validTill.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
          ),
        );
      },
    );
  }
}
