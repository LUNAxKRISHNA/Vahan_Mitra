import 'package:flutter/material.dart';
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
      location: LatLng(9.90, 76.43),
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
                      style: const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: buses.length,
                  itemBuilder: (context, busIndex) {
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
    // Use the same primary color from the login page
    final Color primaryColor = const Color(0xFF0D47A1);

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
            // CHANGED: Label style for light theme
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.grey.shade200,
            // CHANGED: Selected color to match theme
            selectedColor: primaryColor,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300),
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
    // Use the same primary color from the login page
    final Color primaryColor = const Color(0xFF0D47A1);

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 150,
        width: double.infinity,
        // CHANGED: Switched to the light theme gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                  style: TextStyle(
                    // CHANGED: Text color to white for contrast
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your bus in real-time',
                  // CHANGED: Text color to light for contrast
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
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

class _BusInfoCard extends StatelessWidget {
  final Bus bus;
  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final statusColor = bus.status == 'active' ? Colors.green.shade600 : Colors.orange.shade600;
    // Use the same primary color from the login page
    final Color primaryColor = const Color(0xFF0D47A1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
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
                  // CHANGED: Using the primary color for the main icon
                  Icon(Icons.directions_bus, color: primaryColor, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus ${bus.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Text('Route Details', style: TextStyle(color: Colors.black54)),
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
                        color: Colors.white,
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
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}