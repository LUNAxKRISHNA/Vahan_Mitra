import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter.blur
import 'tabs/home_tab.dart';
import 'tabs/buses_page.dart';
import 'tabs/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We now have only 3 tabs as requested
  int _selectedIndex = 0; // Start with Home

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    BusesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body now uses a Stack to allow the glassmorphism effect to work
      body: Stack(
        children: [
          // Your main page content
          IndexedStack(index: _selectedIndex, children: _widgetOptions),
          // The custom navigation bar positioned at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassmorphicNavBar(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

//================================================
// CUSTOM GLASSMORPHIC NAVIGATION BAR
//================================================
class GlassmorphicNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const GlassmorphicNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double navBarHeight = 70;
    const double iconSize = 26;
    const double highlightSize = 55;

    // Calculate the position for the moving highlight
    final double navBarWidth = size.width - 60; // 30 padding on both sides
    final double highlightLeftPosition =
        (navBarWidth / 3) * selectedIndex +
        (navBarWidth / 6) -
        (highlightSize / 2);

    final navBarIcons = [
      Icons.home_filled,
      Icons.directions_bus_filled,
      Icons.person,
    ];

    // This is the main floating container
    return Padding(
      padding: const EdgeInsets.all(
        30.0,
      ), // Creates the space from the bottom/sides
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: navBarHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // The moving highlight circle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: highlightLeftPosition,
                  top: (navBarHeight - highlightSize) / 2,
                  child: Container(
                    width: highlightSize,
                    height: highlightSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 128, 45, 221),
                    ),
                  ),
                ),
                // The row of icons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(navBarIcons.length, (index) {
                      return IconButton(
                        onPressed: () => onTap(index),
                        icon: Icon(
                          navBarIcons[index],
                          size: iconSize,
                          // Change color based on selection
                          color:
                              selectedIndex == index
                                  ? Colors.white
                                  : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
