import 'package:flutter/material.dart';
import 'package:kasir/drawer.dart';
import 'package:kasir/home.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();

  static void toggleTheme() {
    _MainScreenState? mainScreenState = navigatorKey.currentState?.context
        .findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState._toggleTheme();
    }
  }
}

class _MainScreenState extends State<MainScreen> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      // Konfigurasi tema cerah lainnya seperti warna latar belakang, teks, ikon, dll.
      // ...
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      // Konfigurasi tema gelap lainnya seperti warna latar belakang, teks, ikon, dll.
      // ...
    );

    final ThemeData selectedTheme = _isDarkMode ? darkTheme : lightTheme;

    return MaterialApp(
      navigatorKey: MainScreen.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: selectedTheme,
      home: const Scaffold(
        body: Stack(
          children: [
            DrawerScreen(),
            HomeScreen(),
          ],
        ),
      ),
    );
  }
}
