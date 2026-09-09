import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmer AI Assistant',
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: AppRoutes.routes,
    );
  }
}
