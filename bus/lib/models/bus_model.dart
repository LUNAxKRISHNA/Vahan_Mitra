import 'package:google_maps_flutter/google_maps_flutter.dart';

// This should be the entire content of 'lib/models/bus_model.dart'
class Bus {
  final String id;
  final String route;
  final String status;
  final String nextStop;
  final int eta;
  final LatLng location; // The location property that was missing

  const Bus({
    required this.id,
    required this.route,
    required this.status,
    required this.nextStop,
    required this.eta,
    required this.location, // Added this required parameter
  });
}
