import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/Theme_provider.dart';
import 'Screens/Splash_Screeen.dart';
import 'Theme/App_theme.dart';

void main() {
  runApp(const SpinWheelApp());
}

class SpinWheelApp extends StatelessWidget {
  const SpinWheelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Spin Wheel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(), // Changed from HomeScreen to SplashScreen
          );
        },
      ),
    );
  }
}