import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.isDark, required this.onThemeChanged});

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool darkMode;
  bool orderAlerts = true;
  bool stockAlerts = true;
  bool backupAlerts = false;

  @override
  void initState() {
    super.initState();
    darkMode = widget.isDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.apartment)),
              title: const Text('VetCare Distributors'),
              subtitle: const Text('Tap to edit name, logo & GST details'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _toast('Edit profile'),
              ),
            ),
            const Divider(height: 32),
            const Text('App Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              value: darkMode,
              title: const Text('Dark mode'),
              onChanged: (value) {
                setState(() => darkMode = value);
                widget.onThemeChanged(value);
              },
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _toast('Language selector'),
            ),
            const Divider(height: 32),
            const Text('Invoice Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: const InputDecoration(labelText: 'Invoice prefix')), 
            SwitchListTile(
              value: true,
              title: const Text('Show GST Breakdown'),
              onChanged: (_) {},
            ),
            const Divider(height: 32),
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              value: orderAlerts,
              title: const Text('Order alerts'),
              onChanged: (value) => setState(() => orderAlerts = value),
            ),
            SwitchListTile(
              value: stockAlerts,
              title: const Text('Stock alerts'),
              onChanged: (value) => setState(() => stockAlerts = value),
            ),
            SwitchListTile(
              value: backupAlerts,
              title: const Text('Backup reminders'),
              onChanged: (value) => setState(() => backupAlerts = value),
            ),
            const Divider(height: 32),
            const Text('Backup', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Manual backup'),
              subtitle: const Text('Last backup: 18 Nov 2025'),
              onTap: () => _toast('Manual backup'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
