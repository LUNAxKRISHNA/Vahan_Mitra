import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Map<String, dynamic> _config = {};

  Future<void> loadConfig() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/app_config.json',
      );
      _config = json.decode(response);
    } catch (e) {
      debugPrint("Error loading config: $e");
      // Fallback or rethrow depending on needs
    }
  }

  Map<String, dynamic> get ui => _config['ui'] ?? {};
  Map<String, dynamic> get user => _config['user'] ?? {};
  List<dynamic> get drivers => _config['drivers'] ?? [];
  List<dynamic> get routes => _config['routes'] ?? [];

  // Helper to get Color from hex string
  int getColor(String key, {int defaultColor = 0xFF2196F3}) {
    final hexString = ui[key];
    if (hexString != null) {
      return int.tryParse(hexString) ?? defaultColor;
    }
    return defaultColor;
  }
}
