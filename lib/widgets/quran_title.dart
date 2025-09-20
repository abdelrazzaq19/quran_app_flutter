import 'package:flutter/material.dart';

class QuranTile extends StatelessWidget {
  final void Function()? onTap;
  final int versesnumber;
  final String surahName;
  final String revelationPlace;
  final int totalAyah;
  final String surahNameArabic;

  const QuranTile({
    super.key,
    this.onTap,
    required this.versesnumber,
    required this.surahName,
    required this.revelationPlace,
    required this.totalAyah,
    required this.surahNameArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text('$versesnumber'),
      title: Text(
        surahName,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        '$revelationPlace - $totalAyah verses',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      trailing: Text(
        surahNameArabic,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
      ),
    );
  }
}