import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus/controllers/mqtt_service.dart';

// ─── SUPABASE CLIENT ────────────────────────────────────────────────────────
final _supabase = Supabase.instance.client;

Future<Map<String, dynamic>> _loadMockUser() async {
  final user = _supabase.auth.currentUser;
  if (user != null) {
    return {
      'name': user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'Student',
      'email': user.email ?? '',
      'image_url': user.userMetadata?['avatar_url'],
    };
  }
  return {
    'name': 'Student User',
    'email': 'student@college.edu',
    'image_url': null,
  };
}

// ─── USER PROVIDER (mock + SharedPreferences) ────────────────────────────────
class UserNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('user_profile');
    if (savedUser != null) {
      return jsonDecode(savedUser) as Map<String, dynamic>;
    }
    // Fallback to bundled mock user profile
    return _loadMockUser();
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    final current = state.asData?.value ?? {};
    final newData = {...current, ...updatedData};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(newData));
    state = AsyncValue.data(newData);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, Map<String, dynamic>>(() {
  return UserNotifier();
});

// ─── NOTIFICATIONS PROVIDER (live Supabase) ───────────────────────────────
final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await _supabase
      .from('notifications')
      .select('*');
  return response as List<dynamic>;
});

// ─── BUSES PROVIDER (live Supabase via assignments relational join) ───────────
//
// Fetches all active assignments and resolves their related bus, driver, and
// route data in a single Supabase query. The resulting list of bus maps is
// shaped to match the fields already expected by the UI screens:
//   id, name, reg_number, route, driver_name, driver_contact,
//   status, current_stop, current_location {lat, lng}, eta
//
final staticBusesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await _supabase
      .from('assignments')
      .select('id, buses(id, name, bus_no, reg_number, current_location, status), drivers(name, phone), routes(route_name, route_stops(stop_name, stop_order, lat, long))');

  final List<dynamic> assignments = response as List<dynamic>;

  return assignments.map((assignment) {
    final bus     = assignment['buses']    as Map<String, dynamic>?  ?? {};
    final driver  = assignment['drivers']  as Map<String, dynamic>?  ?? {};
    final route   = assignment['routes']   as Map<String, dynamic>?  ?? {};

    final stops = List<Map<String, dynamic>>.from(route['route_stops'] ?? []);
    stops.sort((a, b) => ((a['stop_order'] ?? 0) as int).compareTo((b['stop_order'] ?? 0) as int));

    final currentStop = stops.isNotEmpty ? (stops.first['stop_name'] ?? 'Unknown') : 'Unknown';
    double stopLat     = stops.isNotEmpty ? (stops.first['lat']  ?? 9.882134) : 9.882134;
    double stopLng     = stops.isNotEmpty ? (stops.first['long'] ?? 76.525878) : 76.525878;

    final locStr = bus['current_location'];
    if (locStr != null && locStr is String && locStr.contains(',')) {
      final parts = locStr.split(',');
      stopLat = double.tryParse(parts[0]) ?? stopLat;
      stopLng = double.tryParse(parts[1]) ?? stopLng;
    }

    return <String, dynamic>{
      'id'             : bus['id']        ?? assignment['id'],
      'bus_no'         : bus['bus_no'],
      'name'           : bus['name']      ?? 'Bus #${bus['bus_no'] ?? '—'}',
      'reg_number'     : bus['reg_number'] ?? '—',
      'route'          : route['route_name'] ?? 'Unknown Route',
      'driver_name'    : driver['name']   ?? 'Unknown Driver',
      'driver_contact' : driver['phone']  ?? '—',
      'status'         : bus['status'] ?? 'Offline',
      'current_stop'   : currentStop,
      'current_location': {'lat': stopLat, 'lng': stopLng},
      'eta'            : '—',
      'route_stops'    : stops,
    };
  }).toList();
});

// ─── BUSES PROVIDER (merges Supabase static data + MQTT live location) ────────
final busesProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  try {
    final staticDataAsync = ref.watch(staticBusesProvider);
    final mqttService = ref.watch(mqttServiceProvider);
    final mqttLocations =
        ref.watch(mqttLocationsProvider).asData?.value ?? {};

    if (staticDataAsync.isLoading) {
      return const AsyncValue.loading();
    }
    if (staticDataAsync.hasError) {
      return AsyncValue.error(
          staticDataAsync.error!, staticDataAsync.stackTrace ?? StackTrace.current);
    }

    final staticBuses = List<Map<String, dynamic>>.from(staticDataAsync.asData?.value ?? []);
    if (mqttLocations.isEmpty) return AsyncValue.data(staticBuses);

    final matched = List<bool>.filled(staticBuses.length, false);
    final mergedBuses = List<dynamic>.from(staticBuses);

    for (final entry in mqttLocations.entries) {
      final busKey = entry.key;
      final location = entry.value;

      int targetIndex = -1;

      final explicitBusNo = mqttService.busNoForKey(busKey);
      if (explicitBusNo != null) {
        targetIndex = staticBuses.indexWhere(
          (b) => b['bus_no']?.toString() == explicitBusNo,
        );
      }

      if (targetIndex == -1) {
        targetIndex = staticBuses.indexWhere(
          (b) =>
              b['bus_no']?.toString() == busKey ||
              b['id']?.toString() == busKey,
        );
      }

      if (targetIndex == -1) {
        targetIndex = staticBuses.indexWhere(
          (b) => (b['name'] as String?)?.toLowerCase() == busKey.toLowerCase(),
        );
      }

      if (targetIndex == -1) {
        targetIndex = matched.indexOf(false);
      }

      if (targetIndex != -1) {
        matched[targetIndex] = true;
        mergedBuses[targetIndex] = <String, dynamic>{
          ...staticBuses[targetIndex],
          'current_location': <String, dynamic>{
            'lat': location.lat,
            'lng': location.lng,
          },
          'speed': location.speed,
          'satellites': location.sat,
        };
      }
    }

    return AsyncValue.data(mergedBuses);
  } catch (e, st) {
    debugPrint('[busesProvider] Error: $e\n$st');
    return AsyncValue.error(e, st);
  }
});

// ─── ROUTES PROVIDER (live Supabase with stops) ───────────────────────────────
final routesProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await _supabase
      .from('routes')
      .select('id, route_name, route_stops(stop_name, stop_order)')
      .order('route_name', ascending: true);

  final List<dynamic> routes = response as List<dynamic>;

  final result = routes.map((route) {
    final stops = List<Map<String, dynamic>>.from(route['route_stops'] ?? []);
    stops.sort((a, b) => ((a['stop_order'] ?? 0) as int).compareTo((b['stop_order'] ?? 0) as int));

    return <String, dynamic>{
      'id'   : route['id'],
      'name' : route['route_name'] ?? 'Unnamed Route',
      'stops': stops.map((s) => s['stop_name'] as String? ?? '').toList(),
    };
  }).toList();

  result.sort((a, b) =>
      (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));

  return result;
});

// ─── CURRENT TIME PROVIDER ───────────────────────────────────────────────────
final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
