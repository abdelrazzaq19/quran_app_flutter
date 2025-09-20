import 'package:flutter/material.dart';
import 'package:quran_myapp/core/routes.dart';
// import 'package:quran_myapp/core/themes/text_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrQuran App',
      // theme: ThemeData(textTheme: CustomTextTheme.theme),
      initialRoute: Routes.initialRoute,
      routes: Routes.routes,
    );
  }
}
