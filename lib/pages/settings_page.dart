import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color primaryColor = Color(0xFF313647);

  // Settings state
  bool _enableNotifications = true;
  bool _autoBackup = false;
  int _defaultLoanDays = 7;
  String _dateFormat = 'dd MMM yyyy';
  String _theme = 'light';

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
                      'Settings',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your library system preferences',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  // Settings Sections
                  _buildSettingsSection('General', Icons.settings_outlined, [
                    _buildSwitchTile(
                      'Enable Notifications',
                      'Receive alerts for overdue books and returns',
                      _enableNotifications,
                      (value) => setState(() => _enableNotifications = value),
                    ),
                    _buildSwitchTile(
                      'Auto Backup',
                      'Automatically backup database daily',
                      _autoBackup,
                      (value) => setState(() => _autoBackup = value),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Library Configuration',
                    Icons.library_books_outlined,
                    [
                      _buildDropdownTile(
                        'Default Loan Period',
                        'Number of days for book loans',
                        _defaultLoanDays,
                        [7, 14, 21, 30],
                        (value) => setState(() => _defaultLoanDays = value!),
                      ),
                      _buildDropdownTile(
                        'Date Format',
                        'Format for displaying dates',
                        _dateFormat,
                        [
                          'dd MMM yyyy',
                          'MM/dd/yyyy',
                          'yyyy-MM-dd',
                          'dd-MM-yyyy',
                        ],
                        (value) => setState(() => _dateFormat = value!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection('Appearance', Icons.palette_outlined, [
                    _buildDropdownTile(
                      'Theme',
                      'Application color theme',
                      _theme,
                      ['light', 'dark', 'system'],
                      (value) => setState(() => _theme = value!),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Data Management',
                    Icons.storage_outlined,
                    [
                      _buildActionTile(
                        'Export Database',
                        'Download a backup of all library data',
                        Icons.download,
                        Colors.blue.shade700,
                        () {
                          // TODO: Export database
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export feature coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildActionTile(
                        'Import Database',
                        'Restore data from a backup file',
                        Icons.upload,
                        Colors.green.shade700,
                        () {
                          // TODO: Import database
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Import feature coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildActionTile(
                        'Clear All Data',
                        'Delete all books, members, and records',
                        Icons.delete_forever,
                        Colors.red.shade700,
                        () => _showClearDataDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection('About', Icons.info_outline, [
                    _buildInfoTile('Version', '1.0.0'),
                    _buildInfoTile('Organization', 'Chawnpui Branch YMA'),
                    _buildInfoTile('Developer', 'Literature Sub-Committee'),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    String title,
    String subtitle,
    T value,
    List<T> items,
    Function(T?) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          underline: const SizedBox(),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text(
              'Clear All Data',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all books, members, and issue records. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Clear all data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data cleared successfully'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
