import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../../core/utils/map_marker_generator.dart';

class TrackAllBusesScreen extends ConsumerStatefulWidget {
  const TrackAllBusesScreen({super.key});

  @override
  ConsumerState<TrackAllBusesScreen> createState() =>
      _TrackAllBusesScreenState();
}

class _TrackAllBusesScreenState extends ConsumerState<TrackAllBusesScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  LatLng? _currentLocation;
  final double _currentZoom = 13.0;

  bool _mapReady = false;

  final Map<String, BitmapDescriptor> _busMarkers = {};

  int? _focusedBusIndex;

  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;
  bool _sheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );
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
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  void _focusBus(List<dynamic> buses, int index) {
    setState(() => _focusedBusIndex = index);
    if (!_mapReady) return;
    final bus = buses[index] as Map<String, dynamic>;
    final loc = bus['current_location'] as Map?;
    if (loc == null) return;
    final lat = loc['lat'];
    final lng = loc['lng'];
    if (lat == null || lng == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng((lat as num).toDouble(), (lng as num).toDouble()),
        15.5,
      ),
    );
  }

  void _showAllBuses(List<dynamic> buses) {
    setState(() => _focusedBusIndex = null);
    if (buses.isEmpty || !_mapReady) return;
    
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final b in buses) {
      final loc = (b as Map)['current_location'] as Map?;
      if (loc == null) { continue; }
      final lat = loc['lat'];
      final lng = loc['lng'];
      if (lat == null || lng == null) { continue; }
      final dlat = (lat as num).toDouble();
      final dlng = (lng as num).toDouble();
      if (dlat < minLat) minLat = dlat;
      if (dlat > maxLat) maxLat = dlat;
      if (dlng < minLng) minLng = dlng;
      if (dlng > maxLng) maxLng = dlng;
    }
    if (minLat == double.infinity) return;
    
    if (minLat == maxLat && minLng == maxLng) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 13.0));
    } else {
      final bounds = LatLngBounds(
        southwest: LatLng(minLat - 0.01, minLng - 0.01),
        northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }
  }

  void _toggleSheet() {
    setState(() => _sheetExpanded = !_sheetExpanded);
    if (_sheetExpanded) {
      _sheetController.forward();
    } else {
      _sheetController.reverse();
    }
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
        ),
        child: busesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (buses) {
            _loadBusMarkers(buses);
            final Set<Marker> markers = {};

            if (_focusedBusIndex != null && _focusedBusIndex! < buses.length) {
              final b = buses[_focusedBusIndex!] as Map<String, dynamic>;
              final loc = b['current_location'] as Map?;
              if (loc != null && loc['lat'] != null && loc['lng'] != null) {
                markers.add(Marker(
                  markerId: MarkerId(b['id'].toString()),
                  position: LatLng(
                    (loc['lat'] as num).toDouble(),
                    (loc['lng'] as num).toDouble(),
                  ),
                  icon: _busMarkers[b['id'].toString()] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(title: b['name']?.toString() ?? 'Bus'),
                ));
              }
            } else {
              for (int i = 0; i < buses.length; i++) {
                final b = buses[i] as Map<String, dynamic>;
                final loc = b['current_location'] as Map?;
                if (loc == null || loc['lat'] == null || loc['lng'] == null) { continue; }
                
                BitmapDescriptor icon = _busMarkers[b['id'].toString()] ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

                markers.add(Marker(
                  markerId: MarkerId(b['id'].toString()),
                  position: LatLng(
                    (loc['lat'] as num).toDouble(),
                    (loc['lng'] as num).toDouble(),
                  ),
                  icon: icon,
                  infoWindow: InfoWindow(title: b['name']?.toString() ?? 'Bus'),
                  onTap: () => _focusBus(buses, i),
                ));
              }
            }

            LatLng center = const LatLng(9.882134, 76.525878);
            if (_focusedBusIndex != null && _focusedBusIndex! < buses.length) {
              final b = buses[_focusedBusIndex!] as Map<String, dynamic>;
              final loc = b['current_location'] as Map?;
              if (loc != null && loc['lat'] != null && loc['lng'] != null) {
                center = LatLng(
                  (loc['lat'] as num).toDouble(),
                  (loc['lng'] as num).toDouble(),
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
                    zoom: _currentZoom,
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
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2B8A3E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _focusedBusIndex != null
                                      ? (buses[_focusedBusIndex!]['name']
                                              ?.toString() ??
                                          'Bus')
                                      : 'Track All Buses',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.redAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${buses.length} buses',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.redAccent,
                                      fontSize: 11,
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

                Positioned(
                  right: 16,
                  bottom: _sheetExpanded ? 340 : 200,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentLocation != null && _mapReady) {
                        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
                      } else if (_currentLocation == null) {
                        _getCurrentLocation();
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: AppTheme.neuBoxDecoration(radius: 14),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomBusPanel(
                    buses: buses,
                    focusedIndex: _focusedBusIndex,
                    isExpanded: _sheetExpanded,
                    sheetAnimation: _sheetAnimation,
                    onToggleExpand: _toggleSheet,
                    onBusSelected: (i) => _focusBus(buses, i),
                    onShowAll: () => _showAllBuses(buses),
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

class _BottomBusPanel extends StatelessWidget {
  final List<dynamic> buses;
  final int? focusedIndex;
  final bool isExpanded;
  final Animation<double> sheetAnimation;
  final VoidCallback onToggleExpand;
  final void Function(int) onBusSelected;
  final VoidCallback onShowAll;

  const _BottomBusPanel({
    required this.buses,
    required this.focusedIndex,
    required this.isExpanded,
    required this.sheetAnimation,
    required this.onToggleExpand,
    required this.onBusSelected,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sheetAnimation,
      builder: (context, _) {
        final expandedHeight = MediaQuery.of(context).size.height * 0.45;
        final collapsedHeight = 160.0;
        final height = collapsedHeight +
            (expandedHeight - collapsedHeight) * sheetAnimation.value;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.neuBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: onToggleExpand,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.neuShadowDark,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Buses',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${buses.length}',
                              style: GoogleFonts.inter(
                                color: AppTheme.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (focusedIndex != null)
                            GestureDetector(
                              onTap: onShowAll,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Show All',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: AppTheme.textSecondary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: buses.isEmpty
                    ? Center(
                        child: Text(
                          'No buses available',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: buses.length,
                        separatorBuilder: (ctx, sep) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = buses[i] as Map<String, dynamic>;
                          final isFocused = focusedIndex == i;
                          return _BusListTile(
                            bus: b,
                            isFocused: isFocused,
                            onSwitch: (val) {
                              if (val) {
                                onBusSelected(i);
                              } else {
                                onShowAll();
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BusListTile extends StatelessWidget {
  final Map<String, dynamic> bus;
  final bool isFocused;
  final void Function(bool) onSwitch;

  const _BusListTile({
    required this.bus,
    required this.isFocused,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final status = (bus['status'] as String? ?? 'Offline');
    final isLive = status.toLowerCase() == 'in transit' ||
        status.toLowerCase() == 'running';
    final busName = bus['name']?.toString() ?? 'Bus';
    final busNo = bus['bus_no']?.toString() ?? '';
    final route = bus['route']?.toString() ?? 'Unknown Route';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFocused
            ? AppTheme.primary.withValues(alpha: 0.06)
            : AppTheme.neuBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFocused
              ? AppTheme.primary.withValues(alpha: 0.25)
              : AppTheme.neuShadowDark.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: isFocused
            ? []
            : [
                BoxShadow(
                  color: AppTheme.neuShadowDark.withValues(alpha: 0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
                const BoxShadow(
                  color: AppTheme.neuShadowLight,
                  offset: Offset(-3, -3),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFocused
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : AppTheme.neuShadowDark.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: isFocused ? AppTheme.primary : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        busName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (busNo.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$busNo',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  route,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isLive
                          ? const Color(0xFF2B8A3E)
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isLive ? 'Live' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isLive
                          ? const Color(0xFF2B8A3E)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Transform.scale(
                scale: 0.78,
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isFocused,
                  onChanged: onSwitch,
                  activeThumbColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.25),
                  inactiveThumbColor: AppTheme.textSecondary,
                  inactiveTrackColor:
                      AppTheme.neuShadowDark.withValues(alpha: 0.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
