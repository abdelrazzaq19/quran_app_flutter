import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_myapp/core/config.dart';
import 'package:quran_myapp/models/surah_details.dart';
import 'package:quran_myapp/widgets/surah_card.dart';
// import 'package:quran_myapp/widgets/ayah.dart';
// import 'package:quran_myapp/widgets/surah_card.dart';

class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;
  const SurahDetailsScreen({super.key, required this.surahNumber});

  static const String routeName = '/surah_details';

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  late Future<SurahDetails> data;
  final AudioPlayer player = AudioPlayer();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Stream Subscriptions
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;

  @override
  void initState() {
    super.initState();
    data = _fetchSurah();

    // Listen player state changes
    _playerStateSubscription = player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processingState = state.processingState;
      if (processingState == ProcessingState.completed) {
        // Audio selesai, reset state
        player.seek(Duration.zero);
        player.pause();
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      } else {
        setState(() {
          _isPlaying = playing;
        });
      }
      //audio selesai -> reset state + state play jd pouse
      if (processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
      }
    });

    // Listen duration changes
    _durationSubscription = player.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen position changes
    _positionSubscription = player.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<SurahDetails> _fetchSurah() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseApiUrl}/${widget.surahNumber}.json'),
      );
      if (response.statusCode == 200) {
        return surahDetailsFromJson(response.body);
      } else {
        throw Exception('Failed to load surah details');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to load surah details');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<SurahDetails>(
        future: data,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text(asyncSnapshot.error.toString()));
          } else if (asyncSnapshot.hasData) {
            final surahData = asyncSnapshot.data!;
            final firstReciterAudio =
                (surahData.audio != null && surahData.audio!.isNotEmpty)
                ? surahData.audio!.values.first
                : null;

            return Stack(
              children: [
                // Main scroll view with padding for audio player space
                Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        data = _fetchSurah();
                      });
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Surah Card with pink background and rounded corners
                      SurahCard(surahName: surahData.surahName! , surahNameTranslation: surahData.surahNameTranslation!, totalVerses: surahData.totalAyah!, revelationPlace: surahData.revelationPlace!),

                        if (surahData.surahNo != 1 &&
                            surahData.surahNo != 9) ...[
                          const SizedBox(height: 16),
                          Image.asset(
                            'assets/images/Bismillah.png',
                            height: 100,
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),

                        // List of Ayah with background for verse number and text styles
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemCount: surahData.arabic1?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Verse number with pink background and rounded corners
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Arabic verse text with appropriate font size
                                Text(
                                  surahData.arabic1![index],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // English translation italic and subtler color
                                if (surahData.english != null &&
                                    surahData.english!.length > index)
                                  Text(
                                    surahData.english![index],
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sticky audio player container at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            activeTrackColor: Colors.purple,
                            inactiveTrackColor: Colors.purple.shade100,
                          ),
                          child: Slider(
                            min: 0,
                            max: _duration.inMilliseconds.toDouble(),
                            value: _position.inMilliseconds
                                .clamp(0, _duration.inMilliseconds)
                                .toDouble(),
                            onChanged: (value) async {
                              await player.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                firstReciterAudio?.reciter ?? 'No Reciter',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            FilledButton.icon(
                              onPressed: () async {
                                if (firstReciterAudio?.url != null) {
                                  try {
                                    if (_isPlaying) {
                                      await player.pause();
                                    } else {
                                      if (player.processingState ==
                                          ProcessingState.idle) {
                                        await player.setUrl(
                                          firstReciterAudio!.url!,
                                        );
                                      }
                                      await player.play();
                                    }
                                  } catch (e) {
                                    log('Audio play error: $e');
                                  }
                                }
                              },
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              label: Text(_isPlaying ? 'Pause' : 'Play'),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
