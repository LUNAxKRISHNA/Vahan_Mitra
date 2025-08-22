import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/bus_model.dart';
import '../../widgets/wave_clipper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "map_page.dart";

//==========================================================================

class BusesPage extends StatefulWidget {
  const BusesPage({super.key});
  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _filters = ['All Buses', 'Active', 'Inactive'];

  // Mock data for demonstration
  final List<Bus> _allBuses = [
    const Bus(
      id: '101',
      route: 'Main Campus - Engineering',
      status: 'active',
      nextStop: 'Engineering Building',
      eta: 3,
      driverId: 'D1',
      // Added location for map integration
      location: LatLng(9.9095, 76.4305),
    ),
    const Bus(
      id: '102',
      route: 'Library - Sports Complex',
      status: 'inactive',
      nextStop: 'Central Library',
      eta: 15,
      driverId: 'D2',
      location: LatLng(9.9048, 76.4410),
    ),
    const Bus(
      id: '103',
      route: 'Student Housing - Downtown',
      status: 'active',
      nextStop: 'Oak Street',
      eta: 12,
      driverId: 'D3',
      location: LatLng(9.9073, 76.4384),
    ),
    const Bus(
      id: '104',
      route: 'Science Park - North Gate',
      status: 'inactive',
      nextStop: 'N/A',
      eta: 0,
      driverId: 'D4',
      location: LatLng(9.90, 76.43), // Dummy location
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const _BusesPageHeader(),
          _buildFilterChips(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final buses = _getFilteredBuses(_filters[index]);
                if (buses.isEmpty) {
                  return Center(
                    child: Text(
                      'No buses found for "${_filters[index]}"',
                      style: const TextStyle(color: Color(0xFF222526), fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: buses.length,
                  itemBuilder: (context, busIndex) {
                    // --- UPDATED ---
                    // The _BusInfoCard now handles navigation
                    return _BusInfoCard(bus: buses[busIndex]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Bus> _getFilteredBuses(String filter) {
    if (filter == 'All Buses') {
      return _allBuses;
    } else if (filter == 'Active') {
      return _allBuses.where((bus) => bus.status == 'active').toList();
    } else if (filter == 'Inactive') {
      return _allBuses.where((bus) => bus.status == 'inactive').toList();
    }
    return [];
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_filters.length, (index) {
          final filter = _filters[index];
          final isSelected = _currentIndex == index;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color(0xFFE0E0E0),
            selectedColor: const Color(0xFF1A1A1A),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );
        }),
      ),
    );
  }
}

class _BusesPageHeader extends StatelessWidget {
  const _BusesPageHeader();
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 150,
        width: double.infinity,
        color:const Color(0xFF1A1A1A),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Track Buses',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your bus in real-time',
                  style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Bus Info Card Widget (Updated) ---
class _BusInfoCard extends StatelessWidget {
  final Bus bus;
  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final statusColor = bus.status == 'active' ? Colors.green : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: const Color(0xFF1A1A1A),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to the MapPage, passing the selected bus
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MapPage(bus: bus),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus, color: Color(0xFF222526), size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus ${bus.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(bus.route, style: const TextStyle(color: Color(0xFF222526))),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bus.status.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: 'Next: ${bus.nextStop}',
              ),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.schedule, text: 'ETA: ${bus.eta} min'),
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
  final Widget? trailing;
  const _InfoRow({required this.icon, required this.text, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF222526), size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFF222526))),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the dialer app.')),
    );
  }
}