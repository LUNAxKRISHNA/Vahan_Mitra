import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/mock_data.json');
  return jsonDecode(jsonString);
});

// Selectors for specific chunks of mock data
final userProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.watch(mockDataProvider.future);
  return data['user'];
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
