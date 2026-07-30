import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../../core/utils/map_marker_generator.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? busData;

  const MapScreen({super.key, this.busData});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  LatLng? _currentLocation;

  bool _mapReady = false;

  final Map<String, BitmapDescriptor> _busMarkers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _loadBusMarkers(List<dynamic> buses) async {
    bool hasNew = false;
    int idx = 0;
    for (var b in buses) {
      final bMap = b as Map<String, dynamic>;
      final busId = bMap['id']?.toString() ?? idx.toString();
      final name = bMap['name']?.toString() ?? 'Bus';
      if (!_busMarkers.containsKey(busId)) {
        hasNew = true;
        Color c = Colors.red;
        if (idx % 3 == 0) {
          c = Colors.blue;
        } else if (idx % 3 == 1) {
          c = Colors.green;
        } else {
          c = Colors.orange;
        }
        _busMarkers[busId] = await MapMarkerGenerator.createBusMarker(
          color: c,
          label: name,
        );
      }
      idx++;
    }
    if (hasNew && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
    if (!_mapReady) return;
    if (_currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 16.0),
      );
    } else {
      await _getCurrentLocation();
      if (_currentLocation != null && _mapReady) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 16.0),
        );
      }
    }
  }

  void _callDriver(Map<String, dynamic> activeBus) async {
    if (activeBus['driver_contact'] != null) {
      final url = Uri.parse('tel:${activeBus['driver_contact']}');
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }

  void _showDriverDetailsDialog(Map<String, dynamic> activeBus) {
    final driverName = activeBus['driver_name']?.toString() ?? 'Unknown Driver';
    final driverContact =
        activeBus['driver_contact']?.toString() ?? 'Not Available';
    final busName = activeBus['name']?.toString() ?? 'Bus';
    final busNo = activeBus['bus_no']?.toString() ?? '';

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: AppTheme.neuBoxDecoration(radius: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.neuBoxDecoration(
                      radius: 20,
                      inset: true,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.redAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    driverName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bus Driver • $busName ${busNo.isNotEmpty ? "(#$busNo)" : ""}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: AppTheme.neuBoxDecoration(
                      radius: 12,
                      inset: true,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          driverContact,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.redAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.redAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Safety Disclaimer: The driver may be actively driving. Taking phone calls while driving poses a safety risk. Please refrain from calling unless it is an emergency or urgent query.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              height: 1.35,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: AppTheme.neuBoxDecoration(radius: 14),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _callDriver(activeBus);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.redAccent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.redAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.call_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Call Driver',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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
            ),
          ),
    );
  }

  int _calculateEffectiveSpeed(Map<String, dynamic> busData) {
    final rawSpeed =
        ((busData['speed'] ?? busData['current_location']?['speed'] ?? 0)
                as num)
            .toDouble();
    final rawTs =
        busData['last_updated'] ?? busData['ts'] ?? busData['timestamp'];

    if (rawTs == null) return 0;

    DateTime? dt;
    if (rawTs is DateTime) {
      dt = rawTs;
    } else if (rawTs is String) {
      dt = DateTime.tryParse(rawTs);
    }

    if (dt == null) return 0;

    final diffSeconds = DateTime.now().difference(dt.toLocal()).inSeconds;
    if (diffSeconds < -300 || diffSeconds > 15) {
      return 0;
    }

    return rawSpeed.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final busesAsync = ref.watch(busesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final keralaBounds = LatLngBounds(
      southwest: const LatLng(8.15, 74.85),
      northeast: const LatLng(12.85, 77.55),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: busesAsync.when(
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
          error: (err, stack) => _buildErrorState(err),
          data: (buses) {
            _loadBusMarkers(buses);
            Map<String, dynamic>? activeBus;
            if (widget.busData != null) {
              final id = widget.busData!['id'];
              activeBus =
                  buses.firstWhere(
                        (b) => b['id'] == id,
                        orElse: () => widget.busData!,
                      )
                      as Map<String, dynamic>?;
            }

            final activeBusLocation =
                activeBus != null
                    ? (activeBus['current_location'] as Map?)
                    : null;

            final Set<Marker> markers = {};
            final Set<Polyline> polylines = {};

            if (activeBus != null && activeBusLocation != null) {
              final lat = activeBusLocation['lat'];
              final lng = activeBusLocation['lng'];
              if (lat != null && lng != null) {
                final busLoc = LatLng(
                  (lat as num).toDouble(),
                  (lng as num).toDouble(),
                );
                markers.add(
                  Marker(
                    markerId: MarkerId(activeBus['id'].toString()),
                    position: busLoc,
                    icon: _busMarkers[activeBus['id'].toString()] ?? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: InfoWindow(
                      title: activeBus['name']?.toString() ?? 'Bus',
                    ),
                  ),
                );

                final stops = activeBus['route_stops'] as List<dynamic>? ?? [];
                final points =
                    stops
                        .map((s) {
                          if (s['lat'] != null && s['long'] != null) {
                            return LatLng(
                              (s['lat'] as num).toDouble(),
                              (s['long'] as num).toDouble(),
                            );
                          }
                          return null;
                        })
                        .whereType<LatLng>()
                        .toList();

                if (points.length > 1) {
                  polylines.add(
                    Polyline(
                      polylineId: PolylineId(activeBus['id'].toString()),
                      points: points,
                      color: AppTheme.primary,
                      width: 4,
                    ),
                  );
                }
              }
            } else if (activeBus == null) {
              for (var b in buses) {
                final bMap = b as Map<String, dynamic>;
                final loc = bMap['current_location'] as Map?;
                if (loc == null) { continue; }
                final lat = loc['lat'];
                final lng = loc['lng'];
                if (lat == null || lng == null) { continue; }

                // Color code by index to make them distinct
                BitmapDescriptor icon = _busMarkers[bMap['id'].toString()] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

                markers.add(
                  Marker(
                    markerId: MarkerId(bMap['id'].toString()),
                    position: LatLng(
                      (lat as num).toDouble(),
                      (lng as num).toDouble(),
                    ),
                    icon: icon,
                    infoWindow: InfoWindow(
                      title: bMap['name']?.toString() ?? 'Bus',
                    ),
                  ),
                );
              }
            }

            LatLng center = const LatLng(9.882134, 76.525878);
            if (activeBus != null && activeBusLocation != null) {
              final lat = activeBusLocation['lat'];
              final lng = activeBusLocation['lng'];
              if (lat != null && lng != null) {
                center = LatLng(
                  (lat as num).toDouble(),
                  (lng as num).toDouble(),
                );
              }
            } else if (buses.isNotEmpty) {
              final firstLoc = (buses.first as Map)['current_location'] as Map?;
              if (firstLoc != null &&
                  firstLoc['lat'] != null &&
                  firstLoc['lng'] != null) {
                center = LatLng(
                  (firstLoc['lat'] as num).toDouble(),
                  (firstLoc['lng'] as num).toDouble(),
                );
              }
            }

            return Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 16.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _mapController = controller;
                    _mapReady = true;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  markers: markers,
                  polylines: polylines,
                  cameraTargetBounds: CameraTargetBounds(keralaBounds),
                  minMaxZoomPreference: const MinMaxZoomPreference(8.0, 19.0),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                                  activeBus != null
                                      ? (activeBus['name'] ?? 'Bus Tracker')
                                      : 'All Buses',
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
                                      activeBus['bus_no']?.toString() ??
                                          activeBus['id']?.toString() ??
                                          '1',
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

                if (activeBus != null && activeBusLocation != null)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (context) {
                            final speed = _calculateEffectiveSpeed(activeBus!);
                            final isMoving = speed > 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: AppTheme.neuBoxDecoration(radius: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    color:
                                        isMoving
                                            ? AppTheme.redAccent
                                            : AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$speed km/h',
                                    style: GoogleFonts.poppins(
                                      color:
                                          isMoving
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
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
                            if (!_mapReady) return;
                            final loc = activeBusLocation;
                            final lat = loc['lat'];
                            final lng = loc['lng'];
                            if (lat != null && lng != null) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(
                                    (lat as num).toDouble(),
                                    (lng as num).toDouble(),
                                  ),
                                  15.0,
                                ),
                              );
                            }
                          },
                          onMyLocation: _goToCurrentLocation,
                          onCall: () => _showDriverDetailsDialog(activeBus!),
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

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppTheme.redAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Could not load bus data',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => ref.invalidate(staticBusesProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final regNo =
        busData['reg_number']?.toString() ??
        busData['bus_no']?.toString() ??
        'KL 07 BD 2345';
    final status = busData['status']?.toString() ?? 'Offline';
    final driverName = busData['driver_name']?.toString() ?? 'Driver';
    final lastUpdatedRaw =
        busData['last_updated'] ?? busData['ts'] ?? busData['timestamp'];
    final formattedTime = _formatLastUpdated(lastUpdatedRaw);
    final bool isLive =
        status.toLowerCase() == 'in transit' ||
        status.toLowerCase() == 'running';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neuBoxDecoration(radius: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: AppTheme.neuBoxDecoration(radius: 12, inset: true),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color:
                        isLive
                            ? const Color(0xFF2B8A3E)
                            : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: AppTheme.neuBoxDecoration(radius: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'More Details',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 12),

          Row(
            children: [
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
