import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sceneit/User.dart'; // Your User model
import 'package:sceneit/main.dart';
import 'package:sceneit/utils/session.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(user?.username ?? 'Guest'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Not available'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_language),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Select Language'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'English'),
                      child: const Text('English'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'French'),
                      child: const Text('French'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                setState(() => _language = result);
                _savePreferences();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
