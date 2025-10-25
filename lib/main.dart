import 'package:flutter/material.dart';
import 'models/app_config.dart';
import 'screens/chat_screen.dart';
import 'screens/character_screen.dart';
import 'screens/store_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const UrWaifuApp());

class AppController {
  final ValueNotifier<AppConfig> config = ValueNotifier<AppConfig>(AppConfig());
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  // Temayı değiştir
  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // Yapılandırmayı bütün olarak güncelle
  void updateConfig(AppConfig newConfig) {
    config.value = newConfig;
  }

  // Parayı güncelle
  void addCoins(int amount) {
    final c = config.value;
    updateConfig(c.copyWith(coins: (c.coins + amount).clamp(0, 999999)));
  }

  // Mağaza satın alma
  void purchase(String sku, int price) {
    final c = config.value;
    if (c.ownedSkus.contains(sku)) return;
    if (c.coins < price) return;
    final newOwned = List<String>.from(c.ownedSkus)..add(sku);
    updateConfig(c.copyWith(coins: c.coins - price, ownedSkus: newOwned));
  }
}

class UrWaifuApp extends StatefulWidget {
  const UrWaifuApp({super.key});

  @override
  State<UrWaifuApp> createState() => _UrWaifuAppState();
}

class _UrWaifuAppState extends State<UrWaifuApp> {
  final AppController controller = AppController();
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ChatScreen(controller: controller),
      CharacterScreen(controller: controller),
      StoreScreen(controller: controller),
      SettingsScreen(controller: controller),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'urWaifu 💕',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pinkAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: ValueListenableBuilder<AppConfig>(
              valueListenable: controller.config,
              builder: (context, cfg, _) {
                return NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) => setState(() => _currentIndex = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
                    NavigationDestination(
                      icon: Icon(Icons.face_retouching_natural), label: 'Character'),
                    NavigationDestination(
                      icon: Icon(Icons.storefront_outlined), label: 'Store'),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined), label: 'Settings'),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
