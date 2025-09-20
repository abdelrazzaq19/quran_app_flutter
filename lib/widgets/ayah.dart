import 'package:flutter/material.dart';

class Ayah extends StatelessWidget {
  final int verseNumber;
  final String verseArabic;
  final String verseEnglish;
  const Ayah({
    super.key,
    required this.verseNumber,
    required this.verseArabic,
    required this.verseEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 227, 49, 255).withAlpha(50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            verseNumber.toString(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          verseArabic,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
            fontSize: 28,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        Text(
          verseEnglish,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
