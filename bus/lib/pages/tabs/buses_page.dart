import 'package:flutter/material.dart';
import '../../models/bus_model.dart';
import '../../widgets/wave_clipper.dart';



class BusesPage extends StatefulWidget {
  const BusesPage({super.key});
  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  String _selectedFilter = 'All Buses';
  final List<Bus> _allBuses = const [
    Bus(id: '101', route: 'Main Campus - Engineering', status: 'active', nextStop: 'Engineering Building', eta: 3, fullness: 65, hasWifi: true),
    Bus(id: '202', route: 'Dormitories - Library', status: 'active', nextStop: 'Central Library', eta: 7, fullness: 30, hasWifi: true, hasCharging: true),
    Bus(id: '303', route: 'Campus - Downtown', status: 'delayed', nextStop: 'Student Center', eta: 12, fullness: 85, hasWifi: true),
    Bus(id: '102', route: 'Main Campus - Sports Complex', status: 'active', nextStop: 'Gymnasium', eta: 5, fullness: 40, hasWifi: true),
    Bus(id: '401', route: 'North Campus - Arts Building', status: 'inactive', nextStop: 'Fine Arts Hall', eta: 0, fullness: 0),
  ];

  List<Bus> get _filteredBuses {
    if (_selectedFilter == 'Active') {
      return _allBuses.where((bus) => bus.status == 'active').toList();
    }
    if (_selectedFilter == 'Delayed') {
      return _allBuses.where((bus) => bus.status == 'delayed').toList();
    }
    return _allBuses.where((bus) => bus.status != 'inactive').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BusesPageHeader(),
        _buildFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredBuses.length,
            itemBuilder: (context, index) {
              return _BusInfoCard(bus: _filteredBuses[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['All Buses', 'Active', 'Delayed'].map((filter) {
              bool isSelected = _selectedFilter == filter;
              return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[600],
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey[300]!)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
            }).toList()));
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
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: const SafeArea(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Campus Transit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          Text('Track your bus in real-time',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          SizedBox(height: 30)
                        ])))));
  }
}

class _BusInfoCard extends StatelessWidget {
  final Bus bus;
  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final statusColor = bus.status == 'active' ? Colors.green : Colors.orange;
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: Colors.black12,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(children: [
              Row(children: [
                Icon(Icons.directions_bus, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bus ${bus.id}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(bus.route, style: TextStyle(color: Colors.grey[600]))
                    ]),
                const Spacer(),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(bus.status,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)))
              ]),
              const Divider(height: 24),
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: 'Next: ${bus.nextStop}'),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.schedule, text: 'ETA: ${bus.eta} min'),
              const SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.groups_outlined,
                  text: '${bus.fullness}% full',
                  trailing: Row(children: [
                    if (bus.hasCharging)
                      const Icon(Icons.power, color: Colors.blue, size: 18),
                    if (bus.hasWifi)
                      const Icon(Icons.wifi, color: Colors.blue, size: 18)
                  ]))
            ])));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _InfoRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Colors.grey[600], size: 20),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: Colors.grey[800])),
      const Spacer(),
      if (trailing != null) trailing!
    ]);
  }
}
