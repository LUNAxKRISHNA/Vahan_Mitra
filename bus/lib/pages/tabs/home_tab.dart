// lib/pages/tabs/home_tab.dart
import 'package:bus/pages/tabs/drivers_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Assuming these files exist in your project structure
import '../../models/drivers_model.dart';
import '../../widgets/wave_clipper.dart';

//======================================================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const _HomeTabHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _QuickActionsSection(),
                    const SizedBox(height: 24),
                    const _DriversSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 1. Redesigned Header ---
class _HomeTabHeader extends StatelessWidget {
  const _HomeTabHeader();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 250, // Slightly reduced height
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 61, 65, 38)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Afternoon,',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Vahan Mitra User', // Placeholder for user name
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Color.fromARGB(255, 61, 65, 38),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  dateFormat.format(now),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Quick Actions Section ---
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 61, 65, 38),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionCard(
              icon: Icons.map_outlined,
              label: 'Track My Bus',
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.alt_route,
              label: 'View All Routes',
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.notifications_none,
              label: 'Announcements',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: const Color.fromARGB(255, 61, 65, 38),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
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

// --- 4. Refined Driver Carousel Section ---
class _DriversSection extends StatelessWidget {
  const _DriversSection();

  final List<Drivers> _driversList = const [
    Drivers(
      id: 'D1',
      name: 'Ramesh Kumar',
      phoneNumber: '+91 98765 43210',
      license: 'KL-01-2020-0012345',
      place: 'Kochi',
    ),
    Drivers(
      id: 'D2',
      name: 'Suresh Menon',
      phoneNumber: '+91 91234 56789',
      license: 'KL-07-2018-0054321',
      place: 'Thrissur',
    ),
    Drivers(
      id: 'D3',
      name: 'Anil Varma',
      phoneNumber: '+91 99887 76655',
      license: 'KL-08-2019-0098765',
      place: 'Ernakulam',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Our Drivers',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 61, 65, 38),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriversPage()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Color.fromARGB(255, 61, 65, 38)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _driversList.length,
            itemBuilder: (context, index) {
              return _DriverCarouselCard(driver: _driversList[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _DriverCarouselCard extends StatelessWidget {
  final Drivers driver;
  const _DriverCarouselCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 61, 65, 38),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              driver.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          _buildDriverDetailRow(
            icon: Icons.phone_outlined,
            text: driver.phoneNumber,
          ),
          const SizedBox(height: 8),
          _buildDriverDetailRow(
            icon: Icons.badge_outlined,
            text: driver.license,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
