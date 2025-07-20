import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final memberBox = Hive.box<Member>('member');
      final id = DateTime.now().millisecondsSinceEpoch;
      final now = DateTime.now();
      final member = Member(
        id: id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        joinedDate: now,
        validTill: DateTime(now.year + 1, now.month, now.day),
      );

      memberBox.add(member);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Member'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Phone is required'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveMember, child: const Text('Save')),
      ],
    );
  }
}
