import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? busData;

  const MapScreen({super.key, this.busData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  late LatLng _busLocation;

  @override
  void initState() {
    super.initState();
    // Default or passed location
    if (widget.busData != null && widget.busData!['current_location'] != null) {
      _busLocation = LatLng(
        widget.busData!['current_location']['lat'],
        widget.busData!['current_location']['lng'],
      );
    } else {
      _busLocation = const LatLng(12.9716, 77.5946); // Default Bangalore
    }
  }

  void _callDriver() async {
    if (widget.busData != null && widget.busData!['driver_contact'] != null) {
      final url = Uri.parse('tel:${widget.busData!['driver_contact']}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  void _showInfoSheet() {
    if (widget.busData == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus, color: AppTheme.primary, size: 30),
                const SizedBox(width: 12),
                Text(
                  widget.busData!['name'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.busData!['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Route: ${widget.busData!['route']}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.surface,
                  child: Icon(Icons.person, color: AppTheme.primaryDark),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.busData!['driver_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text('Driver', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: _callDriver,
                  icon: const Icon(Icons.phone, color: AppTheme.primary),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary.withValues(alpha: 0.1)),
                )
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _busLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.vahan_mitra',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _busLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.directions_bus,
                      color: AppTheme.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (widget.busData != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _showInfoSheet,
                child: const Text('View Bus Info'),
              ),
            ),
        ],
      ),
    );
  }
}
