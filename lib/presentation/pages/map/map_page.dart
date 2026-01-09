import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/bus_model.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPage extends StatefulWidget {
  final Bus? bus;
  const MapPage({super.key, this.bus});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Location _locationController = Location();

  MqttServerClient? _mqttClient;
  final String _mqttBroker = 'test.mosquitto.org';
  final String _mqttTopic = 'bus/tracker/location';

  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: 'AIzaSyBcIEYWuyKgOkGdMkRP68w99TCsu1qw25M',
  );

  LatLng? _userCurrentPosition;
  LatLng? _busCurrentLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  BitmapDescriptor? _busIcon;

  @override
  void initState() {
    super.initState();
    _busCurrentLocation = widget.bus?.location;
    _getUserLocationAndSetupMap();
    _setupMqttClient();
  }

  // ---------------- MQTT Setup ----------------
  void _setupMqttClient() async {
    _mqttClient = MqttServerClient(
      _mqttBroker,
      'bus_tracker_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mqttClient!.port = 1883;
    _mqttClient!.logging(on: false);
    _mqttClient!.keepAlivePeriod = 20;
    _mqttClient!.onConnected = _onMqttConnected;

    try {
      await _mqttClient!.connect();
      _mqttClient!.updates!.listen(_onMqttMessage);
      debugPrint('MQTT connected successfully');
    } catch (e) {
      debugPrint('MQTT Exception: $e');
      _mqttClient!.disconnect();
    }
  }

  void _onMqttConnected() {
    debugPrint('MQTT Connected');
    _mqttClient!.subscribe(_mqttTopic, MqttQos.atLeastOnce);
  }

  // ---------------- MQTT message handler ----------------
  void _onMqttMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMessage =
        event[0].payload as MqttPublishMessage;
    final String payload = MqttPublishPayload.bytesToStringAsString(
      recMessage.payload.message,
    );

    try {
      final Map<String, dynamic> data = json.decode(payload);
      final double? latitude = (data['lat'] as num?)?.toDouble();
      final double? longitude = (data['lon'] as num?)?.toDouble();

      if (latitude != null && longitude != null) {
        final LatLng newBusLocation = LatLng(latitude, longitude);

        if (_busCurrentLocation != newBusLocation) {
          setState(() {
            _busCurrentLocation = newBusLocation;
          });
          _updateMapUI();
          _animateCameraToBus();
        }
      }
    } catch (e) {
      debugPrint('MQTT Parsing error: $e\nPayload: $payload');
    }
  }

  // ---------------- Animate camera ----------------
  Future<void> _animateCameraToBus() async {
    if (_busCurrentLocation == null) return;
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_busCurrentLocation!));
  }

  // ---------------- User Location ----------------
  Future<void> _getUserLocationAndSetupMap() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
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
      });
      _updateMapUI();
    }
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
    if (_busCurrentLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('bus_marker'),
          position: _busCurrentLocation!,
          icon:
              _busIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Bus Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // 3. Draw Polyline
    if (_userCurrentPosition != null && _busCurrentLocation != null) {
      try {
        PolylineResult result = await _polylinePoints
            .getRouteBetweenCoordinates(
              // ignore: deprecated_member_use
              request: PolylineRequest(
                origin: PointLatLng(
                  _userCurrentPosition!.latitude,
                  _userCurrentPosition!.longitude,
                ),
                destination: PointLatLng(
                  _busCurrentLocation!.latitude,
                  _busCurrentLocation!.longitude,
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
                  _busCurrentLocation ??
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
          if (widget.bus != null)
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
                                  widget.bus!.route,
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
                              color:
                                  widget.bus!.status == 'active'
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    widget.bus!.status == 'active'
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                            child: Text(
                              widget.bus!.eta > 5 ? 'On Time' : 'Arriving Soon',
                              style: GoogleFonts.poppins(
                                color:
                                    widget.bus!.status == 'active'
                                        ? Colors.green
                                        : Colors.orange,
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
                            widget.bus!.nextStop,
                          ),
                          _buildInfoItem(
                            Icons.access_time,
                            'ETA',
                            '${widget.bus!.eta} min',
                          ),
                          _buildInfoItem(Icons.speed, 'Status', 'Moving'),
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
