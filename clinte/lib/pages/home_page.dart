import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'safe_places_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChildSafetyFeatures(),
    SafePlacesPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeLink: Protect What Matters'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class ChildSafetyFeatures extends StatelessWidget {
  const ChildSafetyFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.child_care, size: 100, color: Colors.deepPurple),
          SizedBox(height: 20),
          Text(
            'Child Safety Features Coming Soon!',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
