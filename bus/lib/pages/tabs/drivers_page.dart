// lib/pages/drivers_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/drivers_model.dart';



const List<Drivers> driversList = [
  Drivers(
    id: 'D1',
    name: 'Ramesh Kumar',
    phoneNumber: '8921522905',
    license: 'KL-01-2020-0012345',
    place: 'Kochi',
    imageUrl: 'assets/drivers/ramesh.png',
  ),
  Drivers(
    id: 'D2',
    name: 'Suresh Menon',
    phoneNumber: '+919123456789',
    license: 'KL-07-2018-0054321',
    place: 'Thrissur',
    imageUrl: 'assets/drivers/suresh.png',
  ),
  Drivers(
    id: 'D3',
    name: 'Anil Varma',
    phoneNumber: '+919988776655',
    license: 'KL-08-2019-0098765',
    place: 'Ernakulam',
    imageUrl: 'assets/drivers/anil.png',
  ),
  Drivers(
    id: 'D4',
    name: 'Biju Nair',
    phoneNumber: '+919555512345',
    license: 'KL-05-2021-0011223',
    place: 'Alappuzha',
    imageUrl: 'assets/drivers/biju.png',
  ),
];

//======================================================================
class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'All Drivers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: driversList.length, // Use the public list
        itemBuilder: (context, index) {
          return _DriverListPageCard(driver: driversList[index]);
        },
      ),
    );
  }
}

// A card widget designed for the vertical list view on this page
class _DriverListPageCard extends StatelessWidget {
  final Drivers driver;
  const _DriverListPageCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFFE0E0E0),
              backgroundImage: AssetImage(driver.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDriverDetailRow(
                    icon: Icons.phone_outlined,
                    text: driver.phoneNumber,
                  ),
                  const SizedBox(height: 4),
                  _buildDriverDetailRow(
                    icon: Icons.badge_outlined,
                    text: driver.license,
                  ),
                   const SizedBox(height: 4),
                  _buildDriverDetailRow(
                    icon: Icons.location_on_outlined,
                    text: driver.place,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF222526), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF222526), fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
