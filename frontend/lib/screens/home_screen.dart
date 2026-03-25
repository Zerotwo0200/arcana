import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'spread_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    SpreadScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A1F4A), width: 1)),
          color: Color(0xFF07061A),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFC8A84B),
          unselectedItemColor: const Color(0xFF5F5E5A),
          elevation: 0,
          selectedLabelStyle: GoogleFonts.cinzel(fontSize: 9, letterSpacing: 2),
          unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 9, letterSpacing: 2),
          items: const [
            BottomNavigationBarItem(
              icon: Text('✦', style: TextStyle(fontSize: 18)),
              label: 'РАСКЛАД',
            ),
            BottomNavigationBarItem(
              icon: Text('☽', style: TextStyle(fontSize: 18)),
              label: 'ИСТОРИЯ',
            ),
            BottomNavigationBarItem(
              icon: Text('◎', style: TextStyle(fontSize: 18)),
              label: 'ПРОФИЛЬ',
            ),
          ],
        ),
      ),
    );
  }
}
