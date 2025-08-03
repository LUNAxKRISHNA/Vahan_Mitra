import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/buses_page.dart';
import 'tabs/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Start with Home (center item)

  static const List<Widget> _widgetOptions = <Widget>[
    BusesPage(),
    HomeTab(),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

//================================================
// CUSTOM BOTTOM NAVIGATION BAR WITH LINE INDICATOR
//================================================
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const indicatorWidth = 40.0; // The width of the moving line
    const indicatorHeight = 4.0;

    // Calculate the position for the moving line indicator
    final double indicatorLeftPosition =
        (screenWidth / 3) * selectedIndex + (screenWidth / 6) - (indicatorWidth / 2);

    return Container(
      // A container to hold the Stack, allowing for a background color and shadow
      height: 80, // Standard height for a bottom nav bar
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // The actual BottomNavigationBar with transparent indicator
          Positioned.fill(
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_bus),
                  label: 'Buses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: onTap,
              // Styling
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Important for the Stack
              elevation: 0,
              selectedItemColor: const Color.fromARGB(255,61,65,38),
              unselectedItemColor: Color.fromARGB(255,61,65,38),
              showSelectedLabels: true,
              showUnselectedLabels: true,
            ),
          ),
          // The custom moving line indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: 0,
            left: indicatorLeftPosition,
            child: Container(
              width: indicatorWidth,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255,61,65,38), // Indicator color
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}