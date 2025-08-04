import 'package:flutter/material.dart';
import '../../models/bus_model.dart';
import '../../widgets/wave_clipper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "map_page.dart";


class BusesPage extends StatefulWidget {
  const BusesPage({super.key});
  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _filters = ['All Buses', 'Active', 'Delayed'];

  // Mock data for demonstration
  final List<Bus> _allBuses = [
    Bus(
      id: '101',
      route: 'Main Campus - Engineering',
      status: 'active',
      nextStop: 'Engineering Building',
      eta: 3,
      // Added location for map integration
      location: LatLng(9.9095, 76.4305),
    ),
    Bus(
      id: '102',
      route: 'Library - Sports Complex',
      status: 'delayed',
      nextStop: 'Central Library',
      eta: 15,
      location: LatLng(9.9048, 76.4410),
    ),
    Bus(
      id: '103',
      route: 'Student Housing - Downtown',
      status: 'active',
      nextStop: 'Oak Street',
      eta: 12,
      location: LatLng(9.9073, 76.4384),
    ),
    Bus(
      id: '104',
      route: 'Science Park - North Gate',
      status: 'inactive',
      nextStop: 'N/A',
      eta: 0,
      location: LatLng(9.90, 76.43), // Dummy location
    ),
  ];

  List<Bus> _getFilteredBuses(String filter) {
    if (filter == 'Active') {
      return _allBuses.where((bus) => bus.status == 'active').toList();
    }
    if (filter == 'Delayed') {
      return _allBuses.where((bus) => bus.status == 'delayed').toList();
    }
    return _allBuses.where((bus) => bus.status != 'inactive').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 41, 44, 26),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey[300]!),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 41, 44, 26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Campus Transit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your bus in real-time',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
    // --- UPDATED ---
    // Wrapped the Card in an InkWell to make it tappable
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
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
                  Icon(Icons.directions_bus, color: Colors.grey[800], size: 30),
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
                      Text(bus.route, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bus.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
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
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[800])),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}