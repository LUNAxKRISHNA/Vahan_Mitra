// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/bus_model.dart';
import '../../../data/repositories/bus_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/config_service.dart';

class MapPage extends StatefulWidget {
  final Bus? bus;
  const MapPage({super.key, this.bus});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  // Services & Repositories
  final BusRepository _busRepository = BusRepository();
  final LocationService _locationService = LocationService();
  late final PolylinePoints _polylinePoints;

  // State
  LatLng? _userCurrentPosition;
  BusLiveStatus? _busStatus; // Dynamic status

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? _busIcon;

  // Streams
  StreamSubscription? _busSubscription;
  StreamSubscription? _userLocationSubscription;

  @override
  void initState() {
    super.initState();
    _polylinePoints = PolylinePoints(apiKey: ConfigService().googleMapsApiKey);

    // Initialize status from repo if bus is provided
    if (widget.bus != null) {
      _busStatus = _busRepository.getBusStatus(widget.bus!.id);
      _busSubscription = _busRepository.streamBusStatus(widget.bus!.id).listen((
        status,
      ) {
        if (!mounted) return;
        setState(() {
          _busStatus = status;
        });
        _updateMapUI();
        _animateCameraToBus();
      });
    }

    _initLocation();
  }

  void _initLocation() async {
    // Get initial location
    final locationData = await _locationService.getUserLocation();
    if (locationData != null &&
        locationData.latitude != null &&
        locationData.longitude != null) {
      if (!mounted) return;
      setState(() {
        _userCurrentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });
      _updateMapUI();
    }

    // Listen to updates
    _userLocationSubscription = _locationService.getLocationStream().listen((
      locationData,
    ) {
      if (locationData.latitude != null && locationData.longitude != null) {
        if (!mounted) return;
        setState(() {
          _userCurrentPosition = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        });
        _updateMapUI();
      }
    });

    // Custom Icon loading could go here (omitted for brevity, or kept if essential)
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    _userLocationSubscription?.cancel();
    super.dispose();
  }

  // ---------------- Animate camera ----------------
  Future<void> _animateCameraToBus() async {
    if (_busStatus == null) return;
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_busStatus!.location));
  }

  // ---------------- Central UI Update Function ----------------
  Future<void> _updateMapUI() async {
    if (!mounted) return;

    final Set<Marker> newMarkers = {};
    final Set<Polyline> newPolylines = {};

    // 1. Add User Marker
    if (_userCurrentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_marker'),
          position: _userCurrentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // 2. Add Bus Marker
    if (_busStatus != null && _busStatus!.location.latitude != 0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('bus_marker'),
          position: _busStatus!.location,
          icon:
              _busIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Bus Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // 3. Draw Polyline
    if (_userCurrentPosition != null &&
        _busStatus != null &&
        _busStatus!.location.latitude != 0) {
      try {
        PolylineResult result = await _polylinePoints
            .getRouteBetweenCoordinates(
              request: PolylineRequest(
                origin: PointLatLng(
                  _userCurrentPosition!.latitude,
                  _userCurrentPosition!.longitude,
                ),
                destination: PointLatLng(
                  _busStatus!.location.latitude,
                  _busStatus!.location.longitude,
                ),
                mode: TravelMode.driving,
              ),
            );

        if (result.points.isNotEmpty) {
          final polylineCoordinates =
              result.points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList();
          newPolylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: const Color(0xFF0D47A1),
              width: 5,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error fetching polyline: $e");
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
      _polylines.clear();
      _polylines.addAll(newPolylines);
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    // If no bus is passed, we show 'Live Map' and finding logic might be different,
    // but for refactor we keep existing behavior.
    final routeName =
        widget.bus != null
            ? _busRepository.getRouteName(widget.bus!.routeId)
            : '';
    final status = _busStatus?.status ?? 'Unknown';
    final eta = _busStatus?.eta ?? 0;

    // Status Logic for Color
    final isStatusActive = status.toLowerCase() == 'active';
    final statusColor = isStatusActive ? Colors.green : Colors.orange;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.bus != null ? 'Bus ${widget.bus!.id}' : 'Live Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController.complete(controller),
            initialCameraPosition: CameraPosition(
              target:
                  _busStatus?.location ??
                  _userCurrentPosition ??
                  const LatLng(9.9073, 76.4384),
              zoom: 14.5,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Bottom Info Card
          if (widget.bus != null && _busStatus != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 30,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bus ${widget.bus!.id}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  routeName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              eta > 5 ? 'On Time' : 'Arriving Soon',
                              style: GoogleFonts.poppins(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            Icons.location_on,
                            'Next Stop',
                            _busStatus!.nextStop,
                          ),
                          _buildInfoItem(Icons.access_time, 'ETA', '$eta min'),
                          _buildInfoItem(Icons.speed, 'Status', status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
