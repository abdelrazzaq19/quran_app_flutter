import 'package:flutter/material.dart';
import 'package:quran_myapp/screen/home_screen.dart';
import 'package:quran_myapp/screen/surah_details_screen.dart';

class Routes {
  static const String initialRoute = HomeScreen.routeName;

  static final Map<String, Widget Function(BuildContext)> routes = {
    HomeScreen.routeName: (context) => const HomeScreen(),
    SurahDetailsScreen.routeName: (context) {
      final int surahNumber = ModalRoute.of(context)!.settings.arguments as int;
      return SurahDetailsScreen(surahNumber: surahNumber);
    },
  };
} 