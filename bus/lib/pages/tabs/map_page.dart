import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/bus_model.dart'; // Import your bus model

class MapPage extends StatefulWidget {
  // Add an optional bus parameter to the constructor to receive data
  final Bus? bus;
  const MapPage({super.key, this.bus});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  // A default location in case no specific bus is passed to the page
  static const LatLng _defaultCenter = LatLng(9.9073, 76.4384);
  
  late LatLng _initialLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Use the passed bus's location, or the default one if no bus is provided
    _initialLocation = widget.bus?.location ?? _defaultCenter;
    _setupMarkers();
  }

  // Prepares the marker for the bus to be displayed on the map
  void _setupMarkers() {
    // Only add a marker if a bus was actually passed to this page
    if (widget.bus != null) {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.bus!.id),
          position: widget.bus!.location,
          infoWindow: InfoWindow(
            title: 'Bus ${widget.bus!.id}',
            snippet: widget.bus!.route,
          ),
          // Using a distinct color for the bus marker
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    // You could add more markers here, for example, for the user's location
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added an AppBar to allow easy navigation back to the previous screen
      appBar: AppBar(
        title: Text(widget.bus != null ? 'Bus ${widget.bus!.id} Location' : 'Live Map'),
        backgroundColor: const Color(0xff2a3a5b),
        elevation: 0,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        // The initial camera position is centered on the selected bus
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 15.0,
        ),
        markers: _markers,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}