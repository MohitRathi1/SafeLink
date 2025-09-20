// components/bottom_nav_bar.dart

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 10, color: Colors.black),
      unselectedLabelStyle: const TextStyle(fontSize: 10, color: Colors.black),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home2.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber,
              color: Colors.white,
              size: 30,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/safeplace.png',
            width: 24,
            height: 24,
          ),
          label: 'Safe place',
        ),
      ],
    );
  }
}