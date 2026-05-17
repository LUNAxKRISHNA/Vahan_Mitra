import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── SUPABASE CLIENT ────────────────────────────────────────────────────────
final _supabase = Supabase.instance.client;

// ─── MOCK DATA (user & announcements — kept as-is) ──────────────────────────
final mockDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString('app_assets/mock_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
});

// ─── USER PROVIDER (mock + SharedPreferences) ────────────────────────────────
class UserNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('user_profile');
    if (savedUser != null) {
      return jsonDecode(savedUser) as Map<String, dynamic>;
    }
    // Fallback to mock data
    final data = await ref.watch(mockDataProvider.future);
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final current = state.value ?? {};
    final newData = {...current, ...updatedData};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(newData));
    state = AsyncValue.data(newData);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, Map<String, dynamic>>(() {
  return UserNotifier();
});

// ─── ANNOUNCEMENTS PROVIDER (mock) ───────────────────────────────────────────
final announcementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ref.watch(mockDataProvider.future);
  return data['announcements'];
});

// ─── BUSES PROVIDER (live Supabase via assignments relational join) ───────────
//
// Fetches all active assignments and resolves their related bus, driver, and
// route data in a single Supabase query. The resulting list of bus maps is
// shaped to match the fields already expected by the UI screens:
//   id, name, reg_number, route, driver_name, driver_contact,
//   status, current_stop, current_location {lat, lng}, eta
//
final busesProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await _supabase
      .from('assignments')
      .select('id, buses(id, name, bus_no, reg_number), drivers(name, phone), routes(route_name, route_stops(stop_name, stop_order, lat, long))');

  final List<dynamic> assignments = response as List<dynamic>;

  return assignments.map((assignment) {
    final bus     = assignment['buses']    as Map<String, dynamic>?  ?? {};
    final driver  = assignment['drivers']  as Map<String, dynamic>?  ?? {};
    final route   = assignment['routes']   as Map<String, dynamic>?  ?? {};

    // Sort stops by stop_order and pick the first as the "current" stop
    final stops = List<Map<String, dynamic>>.from(route['route_stops'] ?? []);
    stops.sort((a, b) => ((a['stop_order'] ?? 0) as int).compareTo((b['stop_order'] ?? 0) as int));

    final currentStop = stops.isNotEmpty ? (stops.first['stop_name'] ?? 'Unknown') : 'Unknown';
    final stopLat     = stops.isNotEmpty ? (stops.first['lat']  ?? 9.882134) : 9.882134;
    final stopLng     = stops.isNotEmpty ? (stops.first['long'] ?? 76.525878) : 76.525878;

    return {
      'id'             : bus['id']        ?? assignment['id'],
      'name'           : bus['name']      ?? 'Bus #${bus['bus_no'] ?? '—'}',
      'reg_number'     : bus['reg_number'] ?? '—',
      'route'          : route['route_name'] ?? 'Unknown Route',
      'driver_name'    : driver['name']   ?? 'Unknown Driver',
      'driver_contact' : driver['phone']  ?? '—',
      'status'         : 'In Transit',
      'current_stop'   : currentStop,
      'current_location': {'lat': stopLat, 'lng': stopLng},
      'eta'            : '—',
    };
  }).toList();
});

// ─── ROUTES PROVIDER (live Supabase with stops) ───────────────────────────────
//
// Fetches all routes along with their stops. Maps to the shape expected by
// the UI: { id, name, stops: [String] }
//
final routesProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await _supabase
      .from('routes')
      .select('id, route_name, route_stops(stop_name, stop_order)')
      .order('id', ascending: true);

  final List<dynamic> routes = response as List<dynamic>;

  return routes.map((route) {
    final stops = List<Map<String, dynamic>>.from(route['route_stops'] ?? []);
    stops.sort((a, b) => ((a['stop_order'] ?? 0) as int).compareTo((b['stop_order'] ?? 0) as int));

    return {
      'id'   : route['id'],
      'name' : route['route_name'] ?? 'Unnamed Route',
      'stops': stops.map((s) => s['stop_name'] as String? ?? '').toList(),
    };
  }).toList();
});

// ─── CURRENT TIME PROVIDER ───────────────────────────────────────────────────
final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
