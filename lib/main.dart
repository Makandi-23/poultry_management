import 'package:flutter/material.dart';
import 'package:poultry_management/screens/Birds_mortality.dart';
import 'package:poultry_management/screens/Birds_purchase.dart';
import 'package:poultry_management/screens/Birds_sales.dart';
import 'package:poultry_management/screens/Feeds_purchase.dart';
import 'package:poultry_management/screens/Orders.dart';
import 'package:poultry_management/screens/dashboard_screen.dart';
import 'package:poultry_management/screens/medicine.dart';
import 'package:poultry_management/screens/payroll.dart';
import 'package:poultry_management/screens/profile.dart';
import 'package:poultry_management/screens/settings.dart';
import 'package:poultry_management/screens/vaccination.dart';
import 'package:poultry_management/screens/welcome_screen.dart';
import 'package:poultry_management/screens/Eggs_production.dart';
import 'package:poultry_management/screens/Eggs_sales.dart';
import 'package:poultry_management/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final _themePreference = ThemePreference();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    bool isDarkMode = await _themePreference.loadThemeMode();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Toggle theme and save preference
  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
    _themePreference.saveThemeMode(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poultry Management',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: _themeMode, 
      home: WelcomeScreen(onThemeChanged: _toggleTheme),
      routes: {
        '/eggsProduction': (context) => EggsProductionScreen(),
        '/eggsSales': (context) => EggsSalesScreen(),
        '/birdsPurchase': (context) => BirdsPurchaseScreen(),
        '/birdsMortality': (context) => BirdsMortalityScreen(),
        '/birdsSales': (context) => BirdsSalesScreen(),
        '/feedPurchase': (context) => FeedsPurchaseScreen(),
        '/profile': (context) => ProfileScreen(),
        '/medicine': (context) => MedicineScreen(),
        '/vaccination': (context) => VaccinationScreen(),
        '/payroll': (context) => PayrollScreen(),
        '/settings': (context) => SettingsScreen(),
        '/orders': (context) => OrdersScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}


class ThemePreference {
  static const _key = 'theme_mode';

  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }

  Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false; // Default to light mode
  }
}
