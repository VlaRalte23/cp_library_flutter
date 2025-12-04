import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:library_chawnpui/helper/member_database.dart';
import 'package:library_chawnpui/models/member.dart';

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _memberSection = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _memberSection.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final member = Member(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        section: _memberSection.text.trim(),

        joinedDate: now,
        validTill: DateTime(now.year + 1, now.month, now.day),
        isActive: true,
      );

      try {
        await MemberDatabase.instance.createMember(member);

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Member Dah Belhna Lamah Buaina a awm tlat mai: $e'),
          ),
        );
        log('Failed to save member: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Member Thar Dah Belh Na'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hming'),
              validator: (value) => value == null || value.isEmpty
                  ? 'I Hming Chhu Lut Rawh'
                  : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'I Phone Number' : null,
            ),
            TextFormField(
              controller: _memberSection,
              decoration: const InputDecoration(labelText: 'Section'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'I Section awmna' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: _saveMember,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Save', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
