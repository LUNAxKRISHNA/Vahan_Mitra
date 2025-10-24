import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/bus_model.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


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

  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: 'AIzaSyBcIEYWuyKgOkGdMkRP68w99TCsu1qw25M');

  LatLng? _userCurrentPosition;
  LatLng? _busCurrentLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _busCurrentLocation = widget.bus?.location;
    // Get user location first, then connect to MQTT
    _getUserLocationAndSetupMap();
    _setupMqttClient();
  }

  @override
  void dispose() {
    _mqttClient?.disconnect();
    super.dispose();
  }

  // ---------------- MQTT Setup ----------------
  void _setupMqttClient() async {
    _mqttClient = MqttServerClient(
      _mqttBroker,
      'bus_tracker_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mqttClient!.port = 1883;
    _mqttClient!.logging(on: false); // Set to true for detailed debugging
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
    final MqttPublishMessage recMessage = event[0].payload as MqttPublishMessage;
    final String payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    try {
      final Map<String, dynamic> data = json.decode(payload);
      final double? latitude = (data['lat'] as num?)?.toDouble();
      final double? longitude = (data['lon'] as num?)?.toDouble();

      if (latitude != null && longitude != null) {
        final LatLng newBusLocation = LatLng(latitude, longitude);

        // Update only if the location has changed to avoid unnecessary rebuilds
        if (_busCurrentLocation != newBusLocation) {
          // Use setState to update the bus location variable
          setState(() {
            _busCurrentLocation = newBusLocation;
          });
          // Call the centralized function to update markers and polylines
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

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _locationController.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      setState(() {
        _userCurrentPosition = LatLng(locationData.latitude!, locationData.longitude!);
      });
      _updateMapUI(); // Call the update function after getting the user's location
    }
  }

  // ---------------- Central UI Update Function ----------------
  Future<void> _updateMapUI() async {
    // A check to ensure the widget is still mounted before calling setState
    if (!mounted) return;

    // Create temporary sets to build the new state
    final Set<Marker> newMarkers = {};
    final Set<Polyline> newPolylines = {};

    // 1. Add User Marker
    if (_userCurrentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_marker'),
          position: _userCurrentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Bus Location'),
        ),
      );
    }

    // 3. Draw Polyline if both locations exist
    if (_userCurrentPosition != null && _busCurrentLocation != null) {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        // ignore: deprecated_member_use
        request: PolylineRequest(
          origin: PointLatLng(_userCurrentPosition!.latitude, _userCurrentPosition!.longitude),
          destination: PointLatLng(_busCurrentLocation!.latitude, _busCurrentLocation!.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        final polylineCoordinates = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        newPolylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.redAccent,
            width: 5,
          ),
        );
      }
    }

    // 4. Update the state with the new markers and polylines
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
      appBar: AppBar(
        title: Text(widget.bus != null ? 'Bus ${widget.bus!.id} Location' : 'Live Map'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController.complete(controller),
        initialCameraPosition: CameraPosition(
          target: _busCurrentLocation ?? _userCurrentPosition ?? const LatLng(9.9073, 76.4384), // Default to a location in Kerala
          zoom: 14.5,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true, // Shows the blue dot for user's location
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}