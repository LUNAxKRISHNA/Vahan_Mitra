import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_model.dart';
import '../services/config_service.dart';

class BusRepository {
  final ConfigService _configService;

  // Cache latest status
  final Map<String, BusLiveStatus> _statusCache = {};

  BusRepository({ConfigService? configService})
    : _configService = configService ?? ConfigService() {
    _initializeCache();
  }

  void _initializeCache() {
    for (var status in _configService.busStatuses) {
      _statusCache[status.busId] = status;
    }
  }

  List<Bus> getBuses() {
    return _configService.buses;
  }

  Bus? getBusById(String id) {
    try {
      return _configService.buses.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  BusLiveStatus getBusStatus(String busId) {
    return _statusCache[busId] ??
        BusLiveStatus(
          busId: busId,
          location: const LatLng(0, 0),
          status: 'Unknown',
        );
  }

  Stream<BusLiveStatus> streamBusStatus(String busId) {
    // Return a stream that emits the current status immediately
    // Since we removed MQTT, this is just a static stream for now.
    // If we wanted to simulate movement, we would use Stream.periodic here.
    // For now, adhering to "remove redundant things", we just return the current known status.
    final status = getBusStatus(busId);
    return Stream.value(status).asBroadcastStream();
  }

  String getRouteName(String routeId) {
    try {
      return _configService.routes.firstWhere((r) => r.id == routeId).name;
    } catch (_) {
      return "Route $routeId";
    }
  }
}
