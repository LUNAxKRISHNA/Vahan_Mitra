// lib/pages/drivers_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming your Drivers model is in this path
import '../../models/drivers_model.dart';

// --- CORRECTED ---
// The list is now a top-level variable (outside the class) and named without
// a leading underscore, making it public and accessible to other files.
final List<Drivers> driversList = const [
  Drivers(
    id: 'D1',
    name: 'Ramesh Kumar',
    phoneNumber: '+919876543210',
    license: 'KL-01-2020-0012345',
    place: 'Kochi',
  ),
  Drivers(
    id: 'D2',
    name: 'Suresh Menon',
    phoneNumber: '+919123456789',
    license: 'KL-07-2018-0054321',
    place: 'Thrissur',
  ),
  Drivers(
    id: 'D3',
    name: 'Anil Varma',
    phoneNumber: '+919988776655',
    license: 'KL-08-2019-0098765',
    place: 'Ernakulam',
  ),
  Drivers(
    id: 'D4',
    name: 'Biju Nair',
    phoneNumber: '+919555512345',
    license: 'KL-05-2021-0011223',
    place: 'Alappuzha',
  ),
];

//======================================================================
class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'All Drivers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 61, 65, 38),
        foregroundColor: Colors.white,
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
                      color: const Color.fromARGB(255, 41, 44, 26),
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
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
