import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/bus_model.dart';
import '../../models/drivers_model.dart';
import 'drivers_page.dart';
//=======================================================
class MapPage extends StatefulWidget {
  final Bus? bus;
  const MapPage({super.key, this.bus});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Location _locationController = Location();
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: 'AIzaSyBcIEYWuyKgOkGdMkRP68w99TCsu1qw25M',
  );

  LatLng? _userCurrentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Drivers? _assignedDriver;

  @override
  void initState() {
    super.initState();
    _findAssignedDriver();
    _getUserLocation();
  }

  // Find the driver associated with the current bus
  void _findAssignedDriver() {
    if (widget.bus != null) {
      setState(() {
        // Search the public list from drivers_page.dart
        _assignedDriver = driversList.firstWhere(
          (driver) => driver.id == widget.bus!.driverId,
          orElse: () => driversList.first, // Fallback to the first driver
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bus != null ? 'Bus ${widget.bus!.id} Location' : 'Live Map'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: widget.bus?.location ?? const LatLng(9.9073, 76.4384),
              zoom: 14.5,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (widget.bus != null && _assignedDriver != null)
            _buildBottomInfoCard(),
        ],
      ),
    );
  }
  Widget _buildBottomInfoCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(
              icon: Icons.directions_bus,
              label: 'Bus Route',
              value: widget.bus?.route ?? 'Unknown Route',
            ),
            const Divider(height: 20),
            InkWell(
              onTap: () => _showDriverDetails(context, _assignedDriver!),
              child: _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Driver',
                value: _assignedDriver!.name,
                showArrow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showArrow = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A1A1A), size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (showArrow)
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }
  void _showDriverDetails(BuildContext context, Drivers driver) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriverDetailSheet(driver: driver),
    );
  }
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _locationController.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      setState(() {
        _userCurrentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _setupMarkers();
        _drawRoute();
      });
    }
  }
  void _setupMarkers() {
    _markers.clear();
    if (widget.bus != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('bus_${widget.bus!.id}'),
          position: widget.bus!.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(title: 'Bus ${widget.bus!.id}'),
        ),
      );
    }
    if (_userCurrentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userCurrentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
  }

  Future<void> _drawRoute() async {
    if (_userCurrentPosition == null || widget.bus == null) return;

    // --- CORRECTED ---
    // The method now uses PolylineRequest and no longer passes the API key,
    // as it's handled in the PolylinePoints constructor.
    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      // ignore: deprecated_member_use
      request: PolylineRequest(
        origin: PointLatLng(
          _userCurrentPosition!.latitude,
          _userCurrentPosition!.longitude,
        ),
        destination: PointLatLng(
          widget.bus!.location.latitude,
          widget.bus!.location.longitude,
        ),
        mode: TravelMode.transit,
      ),
    );

    if (result.points.isNotEmpty) {
      final polylineCoordinates =
          result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.redAccent,
            width: 5,
          ),
        );
      });
    }
  }
}

class _DriverDetailSheet extends StatelessWidget {
  final Drivers driver;
  const _DriverDetailSheet({required this.driver});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
mainAxisSize: MainAxisSize.min,
children: [
  const SizedBox(height: 16),
  Text(
            driver.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 41, 44, 26),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'License: ${driver.license}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
),
const Divider(height: 32),
ElevatedButton(
  onPressed: () async {
              final Uri callUri = Uri(scheme: 'tel', path: driver.phoneNumber);
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open the dialer app.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFE0E0E0),
              backgroundColor: const Color(0xFF1A1A1A),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Call Driver'),
          ),
        ],
      ),
    );
  }
}
