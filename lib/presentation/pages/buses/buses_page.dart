import 'package:flutter/material.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/services/config_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import "../map/map_page.dart" as map_page;

//==========================================================================

class BusesPage extends StatefulWidget {
  const BusesPage({super.key});
  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  List<Bus> _buses = [];

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  void _loadBuses() {
    final busData = ConfigService().buses;
    setState(() {
      _buses =
          busData.map((data) {
            return Bus(
              id: data['id'] ?? 'Unknown',
              route: data['route'] ?? 'Unknown Route',
              status: data['status'] ?? 'unknown',
              nextStop: data['nextStop'] ?? 'Unknown',
              eta: data['eta'] ?? 0,
              driverId: data['driverId'] ?? '',
              location: LatLng(
                (data['lat'] as num?)?.toDouble() ?? 0.0,
                (data['lng'] as num?)?.toDouble() ?? 0.0,
              ),
              image: data['image'] ?? 'assets/bus_placeholder.png',
            );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const _BusesPageHeader(),
          Expanded(
            child:
                _buses.isEmpty
                    ? const Center(child: Text("No buses available"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _buses.length,
                      itemBuilder: (context, index) {
                        return _BusInfoCard(bus: _buses[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _BusesPageHeader extends StatelessWidget {
  const _BusesPageHeader();
  @override
  Widget build(BuildContext context) {
    // Use the same primary color from config if possible, or fallback
    final Color primaryColor = Color(ConfigService().getColor('primary_color'));

    return Container(
      constraints: const BoxConstraints(minHeight: 340),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/header_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Track Buses',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Track your bus in real-time',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusInfoCard extends StatelessWidget {
  final Bus bus;
  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        bus.status == 'active' ? Colors.green.shade600 : Colors.orange.shade600;
    // Use the same primary color from the login page
    final Color primaryColor = Color(ConfigService().getColor('primary_color'));

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => map_page.MapPage(bus: bus)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Bus Image
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(bus.image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Bus Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bus ${bus.id}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            bus.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: bus.nextStop,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.schedule,
                      text: 'ETA: ${bus.eta} min',
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primaryColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
