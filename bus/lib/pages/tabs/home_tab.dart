// lib/pages/tabs/home_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../widgets/wave_clipper.dart';

//======================================================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _HomeTabHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [const _MyBusesSectionHome()]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabHeader extends StatelessWidget {
  const _HomeTabHeader();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEEE d MMM');

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 290,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 61, 65, 38)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vahan Mitra',
                      style: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 246, 237, 222),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CHINMAYA VISHWA VIDYAPEETH',
                      style: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 246, 237, 222),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70), // Added space between rows and time
                Text(
                  timeFormat.format(now),
                  style: GoogleFonts.montserrat(
                    color: Color.fromARGB(255, 246, 237, 222),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(now),
                  style: GoogleFonts.montserrat(
                    color: Color.fromARGB(255, 246, 237, 222),
                    fontSize: 18,
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

class _MyBusesSectionHome extends StatelessWidget {
  const _MyBusesSectionHome();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Buses',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 65, 38),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to buses page
                Navigator.pushNamed(context, '/buses');
              },
              child: Text(
                'View All',
                style: TextStyle(color: Color.fromARGB(255, 61, 65, 38)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Navigate to buses page when card is tapped
            Navigator.pushNamed(context, '/buses');
          },
          child: const _MyBusCardHome(),
        ),
      ],
    );
  }
}

class _MyBusCardHome extends StatelessWidget {
  const _MyBusCardHome();
  @override
  Widget build(BuildContext context) {
    // Replace below with user's alloted/default bus details as needed
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Bus 101',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 61, 65, 38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
