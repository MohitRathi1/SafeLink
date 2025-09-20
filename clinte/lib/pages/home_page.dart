// HomePage.dart
import 'package:flutter/material.dart';
import 'package:clinte/pages/NowMapPage.dart';
import 'package:clinte/pages/MySpotPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeScreenContent(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  List<Map<String, String>> _downloadedMaps = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedMaps();
  }

  Future<void> _loadDownloadedMaps() async {
    final prefs = await SharedPreferences.getInstance();
    final maps = prefs.getStringList('downloaded_maps') ?? [];
    setState(() {
      _downloadedMaps = maps.map((mapString) {
        final parts = mapString.split('|');
        return {'title': parts[0], 'path': parts[1]};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SafeLink',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Hello Welcom, Fill Fearless.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confidence. Connected.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFeatureCard(
                  'Now Map',
                  'assets/saferoutes.png',
                  const Color(0xFFE0F7FA),
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NowMapPage()),
                    );
                    _loadDownloadedMaps(); // Refresh the list after returning from the map page
                  },
                ),
                _buildFeatureCard(
                  'Communities',
                  'assets/communites.png',
                  const Color(0xFFE8F5E9),
                  () {},
                ),
                _buildFeatureCard(
                  'My Spot',
                  'assets/myspot.png',
                  const Color(0xFFFFFDE7),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MySpotPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Image.asset(
                  'assets/saferoutes.png',
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Downloaded Maps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_downloadedMaps.isEmpty)
              const Center(
                child: Text(
                  'No maps downloaded yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._downloadedMaps.map(
                (map) => _buildDownloadedMapCard(map['title']!, map['path']!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String iconPath, Color backgroundColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 40, height: 40),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDownloadedMapCard(String title, String path) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}