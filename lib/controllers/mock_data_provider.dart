import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vahan_mitra/controllers/mqtt_service.dart';

// ─── SUPABASE CLIENT ────────────────────────────────────────────────────────
SupabaseClient get _supabase => Supabase.instance.client;

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

// ─── DEFAULT ROUTE PROVIDER ───────────────────────────────────────────────
class DefaultRouteNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoute = prefs.getString('user_default_route');
    if (savedRoute != null) {
      return jsonDecode(savedRoute) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> setDefaultRoute(Map<String, dynamic> routeData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_default_route', jsonEncode(routeData));
    state = AsyncValue.data(routeData);
  }

  Future<void> clearDefaultRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_default_route');
    state = const AsyncValue.data(null);
  }
}

final defaultRouteProvider = AsyncNotifierProvider<DefaultRouteNotifier, Map<String, dynamic>?>(() {
  return DefaultRouteNotifier();
});


// ─── NOTIFICATIONS PROVIDER (live Supabase) ───────────────────────────────
class NotificationsNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*, admin(name, role)');
      return (response as List<dynamic>?) ?? [];
    } catch (e) {
      debugPrint('Error fetching notifications with admin join: $e');
      try {
        final response = await _supabase
            .from('notifications')
            .select('*');
        final fallbackList = (response as List<dynamic>?) ?? [];
        if (fallbackList.isNotEmpty) {
          fallbackList[0] = {
            ...fallbackList[0] as Map<String, dynamic>,
            'msg_content': '${fallbackList[0]['msg_content']}\n\n[System Error Details: $e]'
          };
        }
        return fallbackList;
      } catch (e2) {
        debugPrint('Fallback error fetching notifications: $e2');
        return [];
      }
    }
  }

  Future<void> markAllAsRead() async {
    final currentNotifications = state.asData?.value ?? [];
    if (currentNotifications.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final allIds = currentNotifications.map((n) => n['id'].toString()).toList();
    await prefs.setStringList('seen_notification_ids', allIds);
    
    // Invalidate the unread state so UI updates immediately
    ref.invalidate(unseenNotificationsProvider);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
    ref.invalidate(unseenNotificationsProvider);
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<dynamic>>(() {
  return NotificationsNotifier();
});

final unseenNotificationsProvider = FutureProvider<bool>((ref) async {
  final notificationsAsync = ref.watch(notificationsProvider);
  
  if (notificationsAsync.isLoading || notificationsAsync.hasError) {
    return false;
  }
  
  final notifications = notificationsAsync.asData?.value ?? [];
  if (notifications.isEmpty) return false;
  
  final prefs = await SharedPreferences.getInstance();
  final seenIds = prefs.getStringList('seen_notification_ids') ?? [];
  
  return notifications.any((n) => !seenIds.contains(n['id'].toString()));
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
    // Periodic time tick so status staleness (>15 min) updates automatically in real-time
    final now = ref.watch(currentTimeProvider).asData?.value ?? DateTime.now();

    if (staticDataAsync.isLoading) {
      return const AsyncValue.loading();
    }
    if (staticDataAsync.hasError) {
      return AsyncValue.error(
          staticDataAsync.error!, staticDataAsync.stackTrace ?? StackTrace.current);
    }

    final staticBuses = List<Map<String, dynamic>>.from(staticDataAsync.asData?.value ?? []);
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
          'last_updated': location.timestamp?.toIso8601String(),
        };
      }
    }

    // Dynamic status determination:
    // If the last update was received less than 15 minutes ago, mark bus as 'In Transit'.
    // Otherwise (or if no update received), mark as 'Offline'.
    final finalBuses = mergedBuses.map((b) {
      final busMap = Map<String, dynamic>.from(b as Map<String, dynamic>);
      final lastUpdatedStr = busMap['last_updated'] as String?;
      String calculatedStatus = 'Offline';

      if (lastUpdatedStr != null) {
        final lastUpdated = DateTime.tryParse(lastUpdatedStr)?.toLocal();
        if (lastUpdated != null) {
          final diffSeconds = now.difference(lastUpdated).inSeconds;
          // Allow up to 5 mins of future clock skew, expire after 15 mins
          if (diffSeconds > -300 && diffSeconds < 900) {
            calculatedStatus = 'In Transit';
          }
        }
      }

      busMap['status'] = calculatedStatus;
      return busMap;
    }).toList();

    return AsyncValue.data(finalBuses);
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
  return Stream.periodic(const Duration(seconds: 60), (_) => DateTime.now());
});
