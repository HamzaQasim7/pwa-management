import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const VetCareApp());
}

class VetCareApp extends StatefulWidget {
  const VetCareApp({super.key});

  @override
  State<VetCareApp> createState() => _VetCareAppState();
}

class _VetCareAppState extends State<VetCareApp> {
  bool isDark = false;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showSplash = false);
      }
    });
  }

  void _handleThemeChange(bool value) {
    setState(() => isDark = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetCare Suite',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: showSplash
            ? const SplashScreen()
            : MainShell(
                key: ValueKey(isDark),
                isDarkMode: isDark,
                onThemeChanged: _handleThemeChange,
              ),
      ),
    );
  }
}
