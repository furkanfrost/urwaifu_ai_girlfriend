import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/memory_manager.dart';

class SettingsScreen extends StatelessWidget {
   final AppController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings ⚙️"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.pinkAccent),
            title: const Text("Dark Mode"),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text("Clear Memory"),
            subtitle: const Text("Forget all past conversations 🧠"),
            onTap: () async {
              await MemoryManager.clearMemory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Memory cleared successfully 🧹")),
              );
            },
          ),
        ],
      ),
    );
  }
}
