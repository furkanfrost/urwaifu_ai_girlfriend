import 'package:flutter/material.dart';
import 'models/app_config.dart';
import 'screens/chat_screen.dart';
import 'screens/character_screen.dart';
import 'screens/store_screen.dart';
import 'screens/settings_screen.dart';
import 'dart:io';

String? globalGroqKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envFile = File("C:/Users/furka/Documents/urwaifu_ai_girlfriend/config.env");
  if (!await envFile.exists()) {
    debugPrint("❌ Config file not found at ${envFile.path}");
  } else {
    final lines = await envFile.readAsLines();
    for (final line in lines) {
      if (line.startsWith("GROQ_API_KEY=")) {
        globalGroqKey = line.split("=")[1].trim();
        debugPrint("✅ Loaded key: ${globalGroqKey?.substring(0, 8)}********");
      }
    }
  }

  runApp(const UrWaifuApp());
}



class AppController {
  final ValueNotifier<AppConfig> config = ValueNotifier<AppConfig>(AppConfig());
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void updateConfig(AppConfig newConfig) => config.value = newConfig;

  void addCoins(int amount) {
    final c = config.value;
    final newCoins = (c.coins + amount).clamp(0, 999999);
    updateConfig(c.copyWith(coins: newCoins));
  }

  void purchase(String sku, int price) {
    final c = config.value;
    if (c.ownedSkus.contains(sku) || c.coins < price) return;
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
          debugShowCheckedModeBanner: false,
          title: 'urWaifu 💕',
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pinkAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[50],
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.pinkAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFF1E1E1E),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Color(0xFF1E1E1E),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          home: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) =>
                    setState(() => _currentIndex = i),
                animationDuration: const Duration(milliseconds: 300),
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline), 
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: 'Chat'),
                  NavigationDestination(
                      icon: Icon(Icons.face_retouching_natural),
                      selectedIcon: Icon(Icons.face_retouching_natural),
                      label: 'Character'),
                  NavigationDestination(
                      icon: Icon(Icons.storefront_outlined), 
                      selectedIcon: Icon(Icons.storefront),
                      label: 'Store'),
                  NavigationDestination(
                      icon: Icon(Icons.settings_outlined), 
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
