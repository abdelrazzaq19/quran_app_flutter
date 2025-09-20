// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_myapp/core/config.dart';
import 'package:quran_myapp/models/surahs.dart';
import 'package:quran_myapp/screen/surah_details_screen.dart';
import 'package:quran_myapp/widgets/quran_title.dart';
// import 'package:google_fonts/google_fonts.dart'; // Tambahkan ini

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Surahs>> data;

  Future<List<Surahs>> _fetchChapters() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseApiUrl}/surah.json'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final List<Surahs> chapters = json
            .map((e) => Surahs.fromJson(e))
            .toList();
        return chapters;
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to load chapters');
    }
  }

  @override
  void initState() {
    super.initState();
    data = _fetchChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE4F5E6,
      ), // Ubah warna latar belakang Scaffold
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              final newData = await _fetchChapters();
              setState(() {
                // Perbaikan: gunakan Future.value untuk menghindari error tipe
                data = Future.value(newData);
              });
            } catch (e) {
              print('Error saat refresh data: $e');
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Bagian Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 255, 187, 247),
                        radius: 24,
                        child: Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 230, 100, 247),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalamu\'alaikum',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ziad',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black54),
                    onPressed: () {
                      // Aksi untuk membuka menu
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kotak "Last Read"
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 244, 140, 245),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Last Read',
                              // style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Surah Al-Baqarah',
                          // style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ayat No: 1',
                          // style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    // Ganti dengan widget gambar atau ikon yang sesuai
                    Image.asset(
                      'assets/images/urr.png', // Sesuaikan path ini
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Bar
              DefaultTabController(
                length: 3,
                child: TabBar(
                  indicatorColor: const Color.fromARGB(255, 226, 97, 255),
                  labelColor: const Color.fromARGB(255, 226, 97, 255),
                  unselectedLabelColor: Colors.black54,
                  // labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Surah'),
                    Tab(text: 'Juz'),
                    Tab(text: 'Page'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // FutureBuilder untuk daftar Surah
              FutureBuilder<List<Surahs>>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.hasData) {
                    return ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1);
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final Surahs surah = snapshot.data![index];
                        return QuranTile(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              SurahDetailsScreen.routeName,
                              arguments: index + 1,
                            );
                          },
                          versesnumber: index + 1,
                          surahName: surah.surahName!,
                          revelationPlace: surah.revelationPlace!,
                          totalAyah: surah.totalAyah!,
                          surahNameArabic: surah.surahNameArabic!,
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
