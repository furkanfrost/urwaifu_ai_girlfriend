import 'package:flutter/material.dart';
import '../main.dart';
import '../models/app_config.dart';

class SettingsScreen extends StatelessWidget {
  final AppController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppConfig>(
      valueListenable: controller.config,
      builder: (context, cfg, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings ⚙️"),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: const TextStyle(
              color: Colors.pinkAccent, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme
              ValueListenableBuilder<ThemeMode>(
                valueListenable: controller.themeMode,
                builder: (context, mode, _) {
                  return SwitchListTile(
                    activeColor: Colors.pinkAccent,
                    title: const Text("Dark Mode"),
                    subtitle: Text(mode == ThemeMode.dark ? "On" : "Off"),
                    value: mode == ThemeMode.dark,
                    onChanged: (_) => controller.toggleTheme(),
                  );
                },
              ),
              const Divider(),

              // Account (dummy)
              ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.pinkAccent),
                title: const Text("Privacy"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Privacy settings coming soon ✨"),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Colors.pinkAccent),
                title: const Text("Notifications"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Notification settings coming soon ✨"),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
              ),
              const Divider(),

              // Character quick actions
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.redAccent),
                title: const Text("Reset Character"),
                subtitle: const Text("Restore default name, avatar and personality"),
                onTap: () {
                  controller.updateConfig(AppConfig());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Character reset to defaults"),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
              ),

              // About
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.pinkAccent),
                title: const Text("About"),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "urWaifu 💕",
                    applicationVersion: "1.0.0",
                    children: const [
                      Text("A lovely AI companion app."),
                      SizedBox(height: 8),
                      Text("Built by Furkan with Flutter."),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
