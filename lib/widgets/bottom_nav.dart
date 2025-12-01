import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sceneit/pages/home.dart';
import 'package:sceneit/pages/watchlist_page.dart';
import 'package:sceneit/pages/Search.dart';
import 'package:flutter/services.dart';
import 'package:sceneit/pages/settings_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    WatchlistPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white.withOpacity(0.09),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          " SceneIt",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.white24, blurRadius: 12)],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),

      body: pages[index],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 22, left: 18, right: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: BottomNavigationBar(
              backgroundColor: Colors.white.withOpacity(0.08),
              elevation: 0,
              currentIndex: index,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              type: BottomNavigationBarType.fixed,
              onTap: (i) => setState(() => index = i),

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded),
                  label: "Watchlist",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
