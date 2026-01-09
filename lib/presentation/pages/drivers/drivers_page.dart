// lib/pages/drivers_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/config_service.dart';

//======================================================================
class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    final driversData = ConfigService().drivers;
    final primaryColor = Color(ConfigService().getColor('primary_color'));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'All Drivers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          driversData.isEmpty
              ? const Center(child: Text("No drivers found"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: driversData.length,
                itemBuilder: (context, index) {
                  final data = driversData[index];
                  return _DriverListPageCard(
                    name: data['name'] ?? '',
                    allocatedBus: data['allocatedBus'] ?? '',
                    license: data['license'] ?? '',
                    place: data['place'] ?? '',
                    phoneNumber: data['phoneNumber'] ?? '',
                  );
                },
              ),
    );
  }
}

// A card widget designed for the vertical list view on this page
class _DriverListPageCard extends StatelessWidget {
  final String name;
  final String allocatedBus;
  final String license;
  final String place;
  final String phoneNumber;

  const _DriverListPageCard({
    required this.name,
    required this.allocatedBus,
    required this.license,
    required this.place,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
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
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDriverDetailRow(
                    icon: Icons.phone_outlined,
                    text: phoneNumber,
                  ),
                  const SizedBox(height: 4),
                  _buildDriverDetailRow(
                    icon: Icons.badge_outlined,
                    text: license,
                  ),
                  const SizedBox(height: 4),
                  _buildDriverDetailRow(
                    icon: Icons.location_on_outlined,
                    text: place,
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
