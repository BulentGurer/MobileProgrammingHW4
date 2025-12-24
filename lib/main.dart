import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hw04/providers/product_provider.dart';
import 'package:hw04/screens/home_screen.dart';
import 'package:provider/provider.dart';

/// [main] Entry point of the application
///
/// Initializes the app and sets up the Provider for state management
void main() {
  if (kDebugMode) {
    print('[main] Starting Product Manager application...');
  }
  runApp(const MyApp());
}

/// [MyApp] Root widget of the application
///
/// Sets up the MaterialApp with a modern theme following Apple's
/// Human Interface Guidelines and wraps the app with ChangeNotifierProvider
/// for state management.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('[MyApp] Building app widget');
    }

    return ChangeNotifierProvider(
      // Create the ProductProvider instance
      create: (context) => ProductProvider(),

      child: MaterialApp(
        // App title
        title: 'Product Manager',

        // Remove debug banner
        debugShowCheckedModeBanner: false,

        // Modern theme inspired by Apple's design language
        theme: ThemeData(
          // Use Material 3 design system
          useMaterial3: true,

          // Color scheme with blue as primary color
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),

          // Typography settings
          fontFamily: 'SF Pro',

          // Card theme for consistent card styling
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Input decoration theme for consistent text field styling
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),

          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Floating action button theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),

        // Home screen
        home: const HomeScreen(),
      ),
    );
  }
}
