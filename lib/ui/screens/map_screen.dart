import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? busData;

  const MapScreen({super.key, this.busData});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  void _goToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    } else {
      await _getCurrentLocation();
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 16.0);
      }
    }
  }

  void _callDriver(Map<String, dynamic> activeBus) async {
    if (activeBus['driver_contact'] != null) {
      final url = Uri.parse('tel:${activeBus['driver_contact']}');
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }



  int _calculateEffectiveSpeed(Map<String, dynamic> busData) {
    final rawSpeed = ((busData['speed'] ?? busData['current_location']?['speed'] ?? 0) as num).toDouble();
    final rawTs = busData['last_updated'] ?? busData['ts'] ?? busData['timestamp'];

    if (rawTs == null) return 0;

    DateTime? dt;
    if (rawTs is DateTime) {
      dt = rawTs;
    } else if (rawTs is String) {
      dt = DateTime.tryParse(rawTs);
    }

    if (dt == null) return 0;

    // If timestamp hasn't updated for > 15 seconds, treat speed as 0 km/h
    final ageInSeconds = DateTime.now().difference(dt.toLocal()).inSeconds.abs();
    if (ageInSeconds > 15) {
      return 0;
    }

    return rawSpeed.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final busesAsync = ref.watch(busesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: busesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (buses) {
          Map<String, dynamic>? activeBus;
          if (widget.busData != null) {
            final id = widget.busData!['id'];
            activeBus = buses.firstWhere(
              (b) => b['id'] == id,
              orElse: () => widget.busData!,
            );
          }

          final List<Marker> markers = [];
          final List<Polyline> polylines = [];

          if (activeBus != null) {
            final lat = activeBus['current_location']['lat'];
            final lng = activeBus['current_location']['lng'];
            final busLoc = LatLng(lat, lng);
            markers.add(Marker(
              point: busLoc,
              width: 120,
              height: 80,
              child: _BusMarker(busName: activeBus['name']),
            ));

            // Polyline for specific bus
            final stops = activeBus['route_stops'] as List<dynamic>? ?? [];
            final points = stops.map((s) {
              if (s['lat'] != null && s['long'] != null) {
                return LatLng((s['lat'] as num).toDouble(), (s['long'] as num).toDouble());
              }
              return null;
            }).whereType<LatLng>().toList();

            if (points.length > 1) {
              polylines.add(
                Polyline(
                  points: points,
                  color: AppTheme.primary,
                  strokeWidth: 4.0,
                ),
              );
            }
          } else {
            // All buses view
            for (var b in buses) {
              final lat = b['current_location']['lat'];
              final lng = b['current_location']['lng'];
              markers.add(Marker(
                point: LatLng(lat, lng),
                width: 120,
                height: 80,
                child: _BusMarker(busName: b['name']),
              ));
            }
          }

          if (_currentLocation != null) {
            markers.add(Marker(
              point: _currentLocation!,
              width: 50,
              height: 50,
              child: _CurrentLocationMarker(),
            ));
          }

          LatLng center = activeBus != null
              ? LatLng(activeBus['current_location']['lat'], activeBus['current_location']['lng'])
              : (buses.isNotEmpty
                  ? LatLng(buses.first['current_location']['lat'], buses.first['current_location']['lng'])
                  : const LatLng(9.882134, 76.525878));

          return Stack(
            children: [
              // ── Map ──────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.vahan_mitra',
                  ),
                  PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              ),

              // ── Top bar ──────────────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: AppTheme.neuBoxDecoration(radius: 14),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: AppTheme.neuBoxDecoration(radius: 18),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_bus_rounded,
                                color: AppTheme.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                activeBus != null ? (activeBus['name'] ?? 'Bus Tracker') : 'All Buses',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (activeBus != null)
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    activeBus['bus_no']?.toString() ?? activeBus['id']?.toString() ?? '1',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Floating Bottom Info Panel & Speed Badge ─────────────────────
              if (activeBus != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating Speed Pill on Top-Left of Panel
                      Builder(
                        builder: (context) {
                          final speed = _calculateEffectiveSpeed(activeBus!);
                          final isMoving = speed > 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: AppTheme.neuBoxDecoration(radius: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  color: isMoving ? AppTheme.redAccent : AppTheme.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$speed km/h',
                                  style: GoogleFonts.poppins(
                                    color: isMoving ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _FloatingBusPanel(
                        busData: activeBus,
                        onFocusBus: () {
                          final loc = LatLng(activeBus!['current_location']['lat'], activeBus['current_location']['lng']);
                          _mapController.move(loc, 15.0);
                        },
                        onMyLocation: _goToCurrentLocation,
                        onCall: () => _callDriver(activeBus!),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _BusMarker extends StatefulWidget {
  final String? busName;

  const _BusMarker({this.busName});

  @override
  State<_BusMarker> createState() => _BusMarkerState();
}

class _BusMarkerState extends State<_BusMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.busName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.busName!,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedBuilder(
          animation: _pulse,
          builder:
              (_, _) => Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.redAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: AppTheme.neuBoxDecoration(radius: 20),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: AppTheme.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }
}

class _CurrentLocationMarker extends StatefulWidget {
  @override
  State<_CurrentLocationMarker> createState() => _CurrentLocationMarkerState();
}

class _CurrentLocationMarkerState extends State<_CurrentLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _ring = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ring,
      builder:
          (_, _) => Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - _ring.value).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1 + _ring.value,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}





class _FloatingBusPanel extends StatelessWidget {
  final Map<String, dynamic> busData;
  final VoidCallback onFocusBus;
  final VoidCallback onMyLocation;
  final VoidCallback onCall;

  const _FloatingBusPanel({
    required this.busData,
    required this.onFocusBus,
    required this.onMyLocation,
    required this.onCall,
  });

  String? _formatLastUpdated(dynamic rawTs) {
    if (rawTs == null) return null;
    DateTime? dt;
    if (rawTs is DateTime) {
      dt = rawTs;
    } else if (rawTs is String) {
      dt = DateTime.tryParse(rawTs);
    }
    if (dt == null) return null;

    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final routeName = busData['route']?.toString() ?? 'College Route';
    final regNo = busData['reg_number']?.toString() ?? busData['bus_no']?.toString() ?? 'KL 07 BD 2345';
    final status = busData['status']?.toString() ?? 'Running';
    final driverName = busData['driver_name']?.toString() ?? 'Driver';
    final lastUpdatedRaw = busData['last_updated'] ?? busData['ts'] ?? busData['timestamp'];
    final formattedTime = _formatLastUpdated(lastUpdatedRaw);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neuBoxDecoration(radius: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Title & Bus Status Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Reg: $regNo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (formattedTime != null) ...[
                          Text(
                            ' • ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.neuBoxDecoration(radius: 12, inset: true),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppTheme.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Driver Call Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.neuBoxDecoration(radius: 16, inset: true),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.neuBoxDecoration(radius: 12),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Bus Driver',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onCall,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.neuBoxDecoration(radius: 12),
                    child: const Icon(
                      Icons.call_rounded,
                      color: AppTheme.redAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 12),

          // Bottom Action Row with 2 black pills distributed equally from the center
          Row(
            children: [
              // Bus Location Black Pill
              Expanded(
                child: GestureDetector(
                  onTap: onFocusBus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bus Location',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // My Location Black Pill
              Expanded(
                child: GestureDetector(
                  onTap: onMyLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Location',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


