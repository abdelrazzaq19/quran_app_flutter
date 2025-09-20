import 'package:flutter/material.dart';

class SurahCard extends StatelessWidget {
  final String surahName;
  final String surahNameTranslation;
  final int totalVerses;
  final String revelationPlace;
  const SurahCard({
    super.key
    , required this.surahName
    , required this.surahNameTranslation 
    , required this.totalVerses
    , required this.revelationPlace
  });

@override
Widget build(BuildContext context) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color.fromARGB(241, 255, 0, 212).withAlpha(50),
      ),
      child: Row(
        children: [
          // Gambar di sebelah kiri
          Expanded(
            flex: 4,
            child: Image.asset(
              'assets/images/${revelationPlace == 'Mecca' ? 'mecca' : 'madinah'}.png',
              fit: BoxFit.cover,
              height: 240,
            ),
          ),
          // Spasi antar gambar dan teks
          const SizedBox(width: 16),
          // Text di sebelah kanan
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    surahName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    surahNameTranslation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text('$totalVerses verses'),
                  Text(revelationPlace),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}