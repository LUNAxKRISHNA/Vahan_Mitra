import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  const BusLocation({
    required this.lat,
    required this.lng,
    this.speed = 0,
    this.sat = 0,
  });

  @override
  String toString() =>
      'BusLocation(lat: $lat, lng: $lng, speed: $speed, sat: $sat)';
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

  late final MqttServerClient _client;
  StreamSubscription? _messageSubscription;

  final _statusController =
      StreamController<MqttConnectionStatus>.broadcast();
  MqttConnectionStatus _status = MqttConnectionStatus.disconnected;

  Stream<Map<String, BusLocation>> get locationStream => _controller.stream;
  Stream<MqttConnectionStatus> get statusStream => _statusController.stream;
  MqttConnectionStatus get status => _status;

  // ── Parse .env mappings ───────────────────────────────────────────────────
  void _buildTopicMap() {
    for (final entry in dotenv.env.entries) {
      if (entry.key.startsWith('MQTT_BUS_')) {
        final busKey = entry.key.substring('MQTT_BUS_'.length);
        _topicToBusKey[entry.value] = busKey;
        debugPrint('[MQTT] Mapped topic "${entry.value}" → busKey "$busKey"');
      }
      if (entry.key.startsWith('MQTT_BUSNO_')) {
        final busKey = entry.key.substring('MQTT_BUSNO_'.length);
        _busKeyToNo[busKey] = entry.value;
        debugPrint('[MQTT] BusKey "$busKey" → Supabase bus_no "${entry.value}"');
      }
    }
  }

  // ── Initialise the MQTT client (TLS, port 8883) ──────────────────────────
  void _initClient() {
    final broker = dotenv.env['MQTT_BROKER'] ?? '';
    // HiveMQ Cloud supports TLS on port 8883 only.
    final port = int.tryParse(dotenv.env['MQTT_PORT'] ?? '8883') ?? 8883;
    final clientId =
        'vahan_mitra_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint('[MQTT] Initialising client → mqtts://$broker:$port');

    _client = MqttServerClient.withPort(broker, clientId, port);
    _client.setProtocolV311();

    // ── TLS (raw, not WebSocket) ────────────────────────────────────────────
    _client.secure = true;
    // Uses the device's trusted CA store — sufficient for HiveMQ Cloud certs.
    _client.securityContext = SecurityContext.defaultContext;

    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;
    _client.logging(on: false);

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;

    _setStatus(MqttConnectionStatus.connecting);
    _connect();
  }

  Future<void> _connect() async {
    try {
      final user = dotenv.env['MQTT_USER'] ?? '';
      final password = dotenv.env['MQTT_PASSWORD'] ?? '';
      
      final result = await _client.connect(user, password);
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

    for (final topic in _topicToBusKey.keys) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
      debugPrint('[MQTT] Subscribed to "$topic"');
    }

    // Cancel any previous subscription before adding a new one
    _messageSubscription?.cancel();
    _messageSubscription = _client.updates?.listen(_handleMessage);
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

  // ── Parse incoming MQTT message ───────────────────────────────────────────
  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final busKey = _topicToBusKey[topic];
      if (busKey == null) {
        debugPrint('[MQTT] Received message on unknown topic: $topic');
        continue;
      }

      final pubMsg = msg.payload as MqttPublishMessage;
      final raw = MqttPublishPayload.bytesToStringAsString(
          pubMsg.payload.message);

      debugPrint('[MQTT] [$topic] payload: $raw');

      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final lat = (json['lat'] as num?)?.toDouble();
        final lng = (json['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) {
          debugPrint('[MQTT] Skipping — missing lat/lng in payload');
          continue;
        }

        _locations[busKey] = BusLocation(
          lat: lat,
          lng: lng,
          speed: (json['speed'] as num?)?.toDouble() ?? 0,
          sat: (json['sat'] as num?)?.toInt() ?? 0,
        );

        _controller.add(Map.unmodifiable(_locations));
        debugPrint('[MQTT] Location updated for "$busKey": $lat, $lng');
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
    _client.disconnect();
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
