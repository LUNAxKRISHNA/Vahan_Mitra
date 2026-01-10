import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bus {
  final String id;
  final String name;
  final String routeId;
  final String driverId;
  final String image;

  const Bus({
    required this.id,
    required this.name,
    required this.routeId,
    required this.driverId,
    required this.image,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['busId'] ?? '',
      name: json['busName'] ?? '',
      routeId: json['routeId'] ?? '',
      driverId: json['driverId'] ?? '',
      image: json['busImage'] ?? 'assets/bus_placeholder.png',
    );
  }
}

class BusLiveStatus {
  final String busId;
  final LatLng location;
  final String currentStop;
  final String nextStop;
  final String status;
  final int eta;

  const BusLiveStatus({
    required this.busId,
    required this.location,
    this.currentStop = '',
    this.nextStop = '',
    this.status = 'Active',
    this.eta = 0,
  });

  factory BusLiveStatus.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    double lat = (loc['lat'] as num?)?.toDouble() ?? 0.0;
    double lng = (loc['lng'] as num?)?.toDouble() ?? 0.0;

    // Fallback for flat JSON structure from MQTT
    if (json.containsKey('lat') && json.containsKey('lon')) {
      lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
      lng = (json['lon'] as num?)?.toDouble() ?? 0.0;
    } else if (json.containsKey('lat') && json.containsKey('lng')) {
      // Support 'lng' key as well if MQTT sends that
      lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
      lng = (json['lng'] as num?)?.toDouble() ?? 0.0;
    }

    return BusLiveStatus(
      busId:
          json['busId'] ?? 'Unknown', // Expected in some payloads, or inferred
      location: LatLng(lat, lng),
      currentStop: json['currentStop'] ?? '',
      nextStop: json['nextStop'] ?? '',
      status: json['status'] ?? 'Active',
      eta: (json['eta'] as num?)?.toInt() ?? 0,
    );
  }
}
