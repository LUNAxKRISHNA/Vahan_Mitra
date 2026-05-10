import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final mockDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString('app_assets/mock_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
});

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
    final userData = data['user'] as Map<String, dynamic>;
    // Ensure sos_contacts is a list
    return userData;
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

final announcementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ref.watch(mockDataProvider.future);
  return data['announcements'];
});

final busesProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ref.watch(mockDataProvider.future);
  return data['buses'];
});

final routesProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ref.watch(mockDataProvider.future);
  return data['routes'];
});

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
