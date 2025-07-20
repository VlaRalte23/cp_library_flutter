import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:library_chawnpui/models/member.dart';
import 'package:library_chawnpui/widgets/add_member_dialog.dart';
import 'package:library_chawnpui/widgets/app_drawer.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member List')),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Member>('member').listenable(),
        builder: (context, Box<Member> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No members added yet.'));
          }

          final members = box.values.toList();
          final activeMembers = members.where((m) => m.isActive).toList();
          final nonActiveMembers = members.where((m) => !m.isActive).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeMembers.length,
                  itemBuilder: (context, index) {
                    final member = activeMembers[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.green),
                        title: Text(member.name),
                        subtitle: Text(member.phone),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Non-Active Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nonActiveMembers.length,
                  itemBuilder: (context, index) {
                    final member = nonActiveMembers[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.person_off,
                          color: Colors.red,
                        ),
                        title: Text(member.name),
                        subtitle: Text(member.phone),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddMemberDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
