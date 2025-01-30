import 'package:flutter/material.dart';

// Updated light color scheme inspired by the wallpaper
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6A5FC3), // Deep purple from the wallpaper
  onPrimary: Color(0xFFFFFFFF), // White text on primary
  secondary: Color(0xFFC1A5F0), // Soft lavender inspired by the lighter shades
  onSecondary: Color(0xFF2A2040), // Dark text for contrast on secondary
  error: Color(0xFFBA1A1A), // Standard error color
  onError: Color(0xFFFFFFFF), // White text on error
  background: Color(0xFFF4F0FA), // Light lavender for background
  onBackground: Color(0xFF2A2040), // Dark text on background
  shadow: Color(0xFF000000), // Standard black shadow
  outlineVariant: Color(0xFFD6CCE2), // Light purple-gray outline
  surface: Color(0xFFFFFFFF), // White surface
  onSurface: Color(0xFF2A2040), // Dark text on surface
);

// Updated dark color scheme inspired by the wallpaper
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF6A5FC3), // Deep purple for dark mode
  onPrimary: Color(0xFFEDE7F6), // Light text on primary
  secondary: Color(0xFFC1A5F0), // Soft lavender for dark mode
  onSecondary: Color(0xFF2A2040), // Dark text for contrast on secondary
  error: Color(0xFFCF6679), // Standard dark mode error color
  onError: Color(0xFF1A1A1A), // Dark background for error text
  background: Color(0xFF1A1A2E), // Dark blue-purple background
  onBackground: Color(0xFFEDE7F6), // Light text on background
  shadow: Color(0xFF000000), // Standard black shadow
  outlineVariant: Color(0xFF4B4375), // Darker purple-gray outline
  surface: Color(0xFF2A2040), // Dark surface color
  onSurface: Color(0xFFEDE7F6), // Light text on surface
);

// Updated ThemeData
ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        lightColorScheme.primary,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      elevation: MaterialStateProperty.all<double>(5.0),
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
);
