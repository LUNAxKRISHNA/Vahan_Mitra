import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/bus_model.dart';
import '../models/driver_model.dart';
import '../models/student_model.dart';
import '../models/route_model.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Map<String, dynamic> _uiConfig = {};
  List<Student> _students = [];
  List<Driver> _drivers = [];
  List<Bus> _buses = [];
  List<BusLiveStatus> _busStatuses = [];
  List<RouteData> _routes = [];

  Future<void> loadConfig() async {
    try {
      // Load UI Config
      final String uiResponse = await rootBundle.loadString(
        'assets/app_config.json',
      );
      _uiConfig = json.decode(uiResponse);

      // Load Students
      final String studentsResponse = await rootBundle.loadString(
        'assets/data/students.json',
      );
      final List<dynamic> studentsJson = json.decode(studentsResponse);
      _students = studentsJson.map((e) => Student.fromJson(e)).toList();

      // Load Drivers
      final String driversResponse = await rootBundle.loadString(
        'assets/data/drivers.json',
      );
      final List<dynamic> driversJson = json.decode(driversResponse);
      _drivers = driversJson.map((e) => Driver.fromJson(e)).toList();

      // Load Buses
      final String busesResponse = await rootBundle.loadString(
        'assets/data/buses.json',
      );
      final List<dynamic> busesJson = json.decode(busesResponse);
      _buses = busesJson.map((e) => Bus.fromJson(e)).toList();
      _busStatuses = busesJson.map((e) => BusLiveStatus.fromJson(e)).toList();

      // Load Routes
      final String routesResponse = await rootBundle.loadString(
        'assets/data/routes.json',
      );
      final List<dynamic> routesJson = json.decode(routesResponse);
      _routes = routesJson.map((e) => RouteData.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error loading config: $e");
    }
  }

  Map<String, dynamic> get ui => _uiConfig['ui'] ?? {};

  String get googleMapsApiKey => _uiConfig['api_keys']?['google_maps'] ?? '';

  Map<String, dynamic> get mqttConfig => _uiConfig['mqtt_config'] ?? {};

  // For backward compatibility or direct access, we can try to map 'user' from app_config
  // to a specific student if needed, but better to use the new student list.
  // For now, let's keep a 'currentUser' getter that returns the first student or a specific one.
  Student? get currentUser => _students.isNotEmpty ? _students.first : null;

  List<Student> get students => _students;
  List<Driver> get drivers => _drivers;
  List<Bus> get buses => _buses;
  List<BusLiveStatus> get busStatuses => _busStatuses;
  List<RouteData> get routes => _routes;

  // Helper to get Color from hex string
  int getColor(String key, {int defaultColor = 0xFF2196F3}) {
    final hexString = ui[key];
    if (hexString != null) {
      return int.tryParse(hexString) ?? defaultColor;
    }
    return defaultColor;
  }
}
