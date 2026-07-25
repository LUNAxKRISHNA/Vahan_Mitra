import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// ─── MODELS ──────────────────────────────────────────────────────────────────

enum MqttConnectionStatus { disconnected, connecting, connected, error }

class BusLocation {
  final double lat;
  final double lng;
  final double speed;
  final int sat;
  final DateTime? timestamp;

  const BusLocation({
    required this.lat,
    required this.lng,
    this.speed = 0,
    this.sat = 0,
    this.timestamp,
  });

  @override
  String toString() =>
      'BusLocation(lat: $lat, lng: $lng, speed: $speed, sat: $sat, timestamp: $timestamp)';
}

// ─── SERVICE ─────────────────────────────────────────────────────────────────

/// Manages a WebSocket-Secure (WSS) connection to HiveMQ Cloud and fans MQTT
/// location payloads out to Riverpod subscribers.
///
/// Bus → topic mapping is driven by .env keys of the form:
///   MQTT_BUS_[busKey]=tracker/bus_01/location
///
/// Bus → Supabase bus_no mapping (optional, for multi-bus matching):
///   MQTT_BUSNO_[busKey]=1
///
/// If MQTT_BUSNO is not set, the live location is applied to the first bus in
/// the Supabase result list (safe for single-bus deployments).
class MqttService {
  MqttService() {
    _buildTopicMap();
    _initClient();
  }

  // topic → busKey  (e.g. "tracker/bus_01/location" → "bus_01")
  final Map<String, String> _topicToBusKey = {};

  // busKey → Supabase bus_no (optional explicit mapping)
  final Map<String, String> _busKeyToNo = {};

  final _controller =
      StreamController<Map<String, BusLocation>>.broadcast();
  final Map<String, BusLocation> _locations = {};

  MqttServerClient? _client;
  StreamSubscription? _messageSubscription;

  final _statusController =
      StreamController<MqttConnectionStatus>.broadcast();
  MqttConnectionStatus _status = MqttConnectionStatus.disconnected;

  Stream<Map<String, BusLocation>> get locationStream => _controller.stream;
  Stream<MqttConnectionStatus> get statusStream => _statusController.stream;
  MqttConnectionStatus get status => _status;

  // ── Parse config mappings ───────────────────────────────────────────────────
  void _buildTopicMap() {
    const configStr = String.fromEnvironment('MQTT_BUS_CONFIG');
    if (configStr.isEmpty) {
      debugPrint('[MQTT] Warning: MQTT_BUS_CONFIG is empty or not provided.');
      return;
    }

    try {
      final config = jsonDecode(configStr) as Map<String, dynamic>;
      for (final entry in config.entries) {
        final busKey = entry.key;
        final data = entry.value as Map<String, dynamic>;
        
        final topic = data['topic'] as String?;
        final busNo = data['bus_no']?.toString();

        if (topic != null) {
          _topicToBusKey[topic] = busKey;
          debugPrint('[MQTT] Mapped topic "$topic" → busKey "$busKey"');
        }
        if (busNo != null) {
          _busKeyToNo[busKey] = busNo;
          debugPrint('[MQTT] BusKey "$busKey" → Supabase bus_no "$busNo"');
        }
      }
    } catch (e) {
      debugPrint('[MQTT] Error parsing MQTT_BUS_CONFIG: $e');
    }
  }

  // ── Initialise the MQTT client (TLS, port 8883) ──────────────────────────
  void _initClient() {
    try {
      if (kIsWeb) {
        debugPrint('[MQTT] Web target detected — TCP sockets (SecurityContext) unsupported on web browsers.');
        _setStatus(MqttConnectionStatus.disconnected);
        return;
      }

      const broker = String.fromEnvironment('MQTT_BROKER');
      // HiveMQ Cloud supports TLS on port 8883 only.
      const portStr = String.fromEnvironment('MQTT_PORT', defaultValue: '8883');
      final port = int.tryParse(portStr) ?? 8883;
      final clientId =
          'vahan_mitra_${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('[MQTT] Initialising client → mqtts://$broker:$port');

      if (broker.isEmpty) {
        debugPrint('[MQTT] Error: MQTT_BROKER is empty or not provided.');
        _setStatus(MqttConnectionStatus.error);
        return;
      }

      _client = MqttServerClient.withPort(broker, clientId, port);
      _client?.setProtocolV311();

      // ── TLS (raw, not WebSocket) ────────────────────────────────────────────
      _client?.secure = true;
      // Uses the device's trusted CA store — sufficient for HiveMQ Cloud certs.
      _client?.securityContext = SecurityContext.defaultContext;

      _client?.keepAlivePeriod = 30;
      _client?.autoReconnect = true;
      _client?.logging(on: false);

      _client?.onConnected = _onConnected;
      _client?.onDisconnected = _onDisconnected;
      _client?.onAutoReconnect = _onAutoReconnect;
      _client?.onAutoReconnected = _onAutoReconnected;

      _setStatus(MqttConnectionStatus.connecting);
      _connect();
    } catch (e, st) {
      debugPrint('[MQTT] Exception initializing client: $e\n$st');
      _setStatus(MqttConnectionStatus.error);
    }
  }

  Future<void> _connect() async {
    try {
      const user = String.fromEnvironment('MQTT_USER');
      const password = String.fromEnvironment('MQTT_PASSWORD');
      
      final result = await _client?.connect(user, password);
      debugPrint('[MQTT] Connect result: ${result?.state}');
    } catch (e, st) {
      debugPrint('[MQTT] Connect error: $e\n$st');
      _setStatus(MqttConnectionStatus.error);
    }
  }

  // ── Connection callbacks ──────────────────────────────────────────────────
  void _onConnected() {
    debugPrint('[MQTT] Connected ✓');
    _setStatus(MqttConnectionStatus.connected);

    const envTopic = String.fromEnvironment('MQTT_TOPIC');
    if (envTopic.isEmpty && _topicToBusKey.isEmpty) {
      debugPrint('[MQTT] Warning: MQTT_TOPIC is empty or not provided in .env.');
    }

    final topicsToSubscribe = <String>{
      if (envTopic.isNotEmpty) envTopic,
      ..._topicToBusKey.keys,
    };

    for (final topic in topicsToSubscribe) {
      if (topic.isNotEmpty) {
        _client?.subscribe(topic, MqttQos.atLeastOnce);
        debugPrint('[MQTT] Subscribed to "$topic"');
      }
    }

    // Cancel any previous subscription before adding a new one
    _messageSubscription?.cancel();
    _messageSubscription = _client?.updates?.listen(_handleMessage);
  }

  void _onDisconnected() {
    debugPrint('[MQTT] Disconnected');
    _setStatus(MqttConnectionStatus.disconnected);
  }

  void _onAutoReconnect() {
    debugPrint('[MQTT] Auto-reconnecting…');
    _setStatus(MqttConnectionStatus.connecting);
  }

  void _onAutoReconnected() {
    debugPrint('[MQTT] Auto-reconnected ✓ — re-subscribing');
    _onConnected(); // re-subscribe after reconnect
  }

  // ── Extract busKey from topic ─────────────────────────────────────────────
  String? _extractBusKey(String topic) {
    // 1. Direct lookup in static config mapping
    if (_topicToBusKey.containsKey(topic)) {
      return _topicToBusKey[topic];
    }

    // 2. Wildcard pattern matching based strictly on MQTT_TOPIC from env
    const envTopic = String.fromEnvironment('MQTT_TOPIC');
    if (envTopic.isNotEmpty) {
      final escaped = RegExp.escape(envTopic)
          .replaceAll(r'\+', '([^/]+)')
          .replaceAll(r'\#', '(.*)');
      final regexString = '^$escaped\$';
      final regex = RegExp(regexString);
      final match = regex.firstMatch(topic);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    // 3. Fallback: split topic segments if topic format is multi-segment
    final parts = topic.split('/');
    if (parts.length >= 3) {
      return parts[parts.length - 2];
    }

    return null;
  }

  // ── Parse incoming MQTT message ───────────────────────────────────────────
  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final busKey = _extractBusKey(topic);
      if (busKey == null) {
        debugPrint('[MQTT] Received message on unknown topic structure: $topic');
        continue;
      }

      final pubMsg = msg.payload as MqttPublishMessage;
      final raw = MqttPublishPayload.bytesToStringAsString(
          pubMsg.payload.message);

      debugPrint('[MQTT] [$topic] (busKey: $busKey) payload: $raw');

      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final lat = (json['lat'] as num? ?? json['latitude'] as num?)?.toDouble();
        final lng = (json['lng'] as num? ?? json['longitude'] as num? ?? json['long'] as num?)?.toDouble();
        if (lat == null || lng == null) {
          debugPrint('[MQTT] Skipping — missing lat/lng in payload');
          continue;
        }

        DateTime? parsedTime;
        final tsRaw = json['ts'] ?? json['timestamp'] ?? json['last_updated'];
        if (tsRaw != null) {
          if (tsRaw is num) {
            parsedTime = tsRaw > 10000000000
                ? DateTime.fromMillisecondsSinceEpoch(tsRaw.toInt(), isUtc: true)
                : DateTime.fromMillisecondsSinceEpoch((tsRaw * 1000).toInt(), isUtc: true);
          } else if (tsRaw is String) {
            parsedTime = DateTime.tryParse(tsRaw);
          }
        }
        parsedTime ??= DateTime.now();

        _locations[busKey] = BusLocation(
          lat: lat,
          lng: lng,
          speed: (json['speed'] as num?)?.toDouble() ?? 0,
          sat: (json['sat'] as num? ?? json['satellites'] as num?)?.toInt() ?? 0,
          timestamp: parsedTime,
        );

        _controller.add(Map.unmodifiable(_locations));
        debugPrint('[MQTT] Location updated for busKey "$busKey": $lat, $lng');
      } catch (e) {
        debugPrint('[MQTT] Failed to parse payload: $e  raw="$raw"');
      }
    }
  }

  void _setStatus(MqttConnectionStatus s) {
    _status = s;
    _statusController.add(s);
  }

  // ── Public helper: which Supabase bus_no does a busKey map to? ───────────
  /// Returns the explicit bus_no from .env (MQTT_BUSNO_*) if set,
  /// otherwise null — callers should fall back to first-bus logic.
  String? busNoForKey(String busKey) => _busKeyToNo[busKey];

  // ── Cleanup ───────────────────────────────────────────────────────────────
  void dispose() {
    _messageSubscription?.cancel();
    _client?.disconnect();
    _controller.close();
    _statusController.close();
  }
}

// ─── RIVERPOD PROVIDERS ───────────────────────────────────────────────────────

final mqttServiceProvider = Provider<MqttService>((ref) {
  final service = MqttService();
  ref.onDispose(service.dispose);
  return service;
});

/// Live stream of bus locations keyed by busKey (e.g. "bus_01").
/// Rebuilds whenever any bus publishes a new location.
final mqttLocationsProvider =
    StreamProvider<Map<String, BusLocation>>((ref) {
  return ref.watch(mqttServiceProvider).locationStream;
});

/// MQTT connection status stream.
final mqttStatusProvider =
    StreamProvider<MqttConnectionStatus>((ref) {
  final svc = ref.watch(mqttServiceProvider);
  return _statusStreamWithCurrent(svc);
});

Stream<MqttConnectionStatus> _statusStreamWithCurrent(
    MqttService svc) async* {
  yield svc.status;
  yield* svc.statusStream;
}
