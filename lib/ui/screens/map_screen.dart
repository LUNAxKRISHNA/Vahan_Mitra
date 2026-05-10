import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? busData;

  const MapScreen({super.key, this.busData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  late LatLng _busLocation;
  LatLng? _currentLocation;
  bool _loadingLocation = false;
  bool _showBusInfo = false;
  late AnimationController _infoSheetController;
  late Animation<double> _infoSheetAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.busData != null && widget.busData!['current_location'] != null) {
      _busLocation = LatLng(
        widget.busData!['current_location']['lat'],
        widget.busData!['current_location']['lng'],
      );
    } else {
      _busLocation = const LatLng(9.882134, 76.525878);
    }

    _infoSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _infoSheetAnimation = CurvedAnimation(
      parent: _infoSheetController,
      curve: Curves.easeOutQuint,
    );

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _infoSheetController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
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

  void _callDriver() async {
    if (widget.busData != null && widget.busData!['driver_contact'] != null) {
      final url = Uri.parse('tel:${widget.busData!['driver_contact']}');
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }

  void _toggleBusInfo() {
    setState(() => _showBusInfo = !_showBusInfo);
    if (_showBusInfo) {
      _infoSheetController.forward();
    } else {
      _infoSheetController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _busLocation, initialZoom: 15.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.vahan_mitra',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _busLocation,
                    width: 60,
                    height: 60,
                    child: _BusMarker(),
                  ),
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: _CurrentLocationMarker(),
                    ),
                ],
              ),
            ],
          ),

          // ── Top gradient overlay ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.gradientDark.withValues(alpha: 0.85),
                    AppTheme.gradientDark.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _GlassButton(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.busData != null
                                ? widget.busData!['name'] ?? 'Bus Tracker'
                                : 'Bus Tracker',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (widget.busData != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.busData!['status'] ?? 'Live',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
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

          // ── Right-side control buttons ────────────────────────────
          Positioned(
            right: 16,
            bottom: widget.busData != null ? 240 : 100,
            child: Column(
              children: [
                _MapControlButton(
                  icon: Icons.add,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.remove,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: _loadingLocation ? null : Icons.my_location_rounded,
                  isLoading: _loadingLocation,
                  highlighted: true,
                  onTap: _goToCurrentLocation,
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.directions_bus_rounded,
                  onTap: () => _mapController.move(_busLocation, 15.0),
                ),
              ],
            ),
          ),

          // ── Bottom info panel ─────────────────────────────────────
          if (widget.busData != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BusInfoPanel(
                busData: widget.busData!,
                isExpanded: _showBusInfo,
                animation: _infoSheetAnimation,
                onToggle: _toggleBusInfo,
                onCall: _callDriver,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _BusMarker extends StatefulWidget {
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
    return AnimatedBuilder(
      animation: _pulse,
      builder:
          (_, _) => Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
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

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;
  final bool highlighted;
  final bool isLoading;

  const _MapControlButton({
    this.icon,
    required this.onTap,
    this.highlighted = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child:
              isLoading
                  ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: highlighted ? Colors.white : AppTheme.primary,
                    ),
                  )
                  : Icon(
                    icon,
                    color: highlighted ? Colors.white : AppTheme.primary,
                    size: 20,
                  ),
        ),
      ),
    );
  }
}

class _BusInfoPanel extends StatelessWidget {
  final Map<String, dynamic> busData;
  final bool isExpanded;
  final Animation<double> animation;
  final VoidCallback onToggle;
  final VoidCallback onCall;

  const _BusInfoPanel({
    required this.busData,
    required this.isExpanded,
    required this.animation,
    required this.onToggle,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              busData['name'] ?? 'Bus',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              busData['route'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          busData['status'] ?? 'Live',
                          style: GoogleFonts.inter(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded section
          SizeTransition(
            sizeFactor: animation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'ETA',
                    value: busData['eta'] ?? '~8 min',
                    iconColor: AppTheme.accent,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.route_rounded,
                    label: 'Route',
                    value: busData['route'] ?? 'N/A',
                    iconColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                busData['driver_name'] ?? 'Driver',
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
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.call_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.08),
                          AppTheme.accent.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Live tracking active',
                          style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (!isExpanded) const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
