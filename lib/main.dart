import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/main_menu_page.dart';
import '../controllers/theme_controller.dart';
 // pastikan path sesuai

void main() {
  // Daftarkan ThemeController di awal
  Get.put(ThemeController());
  runApp(const GangnamLaundryApp());
}

class GangnamLaundryApp extends StatelessWidget {
  const GangnamLaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gangnam Laundry',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: themeController.themeMode.value,
        home: const MainMenuPage(),
      ),
    );
  }
}

/// Light Theme
ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.lightBlue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Colors.lightBlue.shade50,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.lightBlue,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: Colors.lightBlue.shade50,
  );
}

/// Dark Theme
ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.lightBlueAccent,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
