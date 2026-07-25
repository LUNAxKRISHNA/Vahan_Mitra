import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  int _selectedRouteIndex = 0;
  late PageController _pageController;
  late ScrollController _chipScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedRouteIndex);
    _chipScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  void _scrollToChip(int index) {
    if (!_chipScrollController.hasClients) return;
    final double targetOffset = (index * 110.0 - 100.0).clamp(
      0.0,
      _chipScrollController.position.maxScrollExtent,
    );
    _chipScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routesProvider);
    final busesAsync = ref.watch(staticBusesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Campus Routes',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(child: Text('No routes available.'));
          }

          return Column(
            children: [
              // Route Selector Chips (Swipe Sync & Clickable)
              if (routes.length > 1) ...[
                const SizedBox(height: 4),
                SingleChildScrollView(
                  controller: _chipScrollController,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(routes.length, (index) {
                      final isSelected = index == _selectedRouteIndex;
                      final rName = routes[index]['name'] ?? 'Route ${index + 1}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                            _scrollToChip(index);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: isSelected
                                ? AppTheme.neuBoxDecoration(radius: 20)
                                : BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: Text(
                              rName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppTheme.redAccent : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Swappable Pages for Routes
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedRouteIndex = index;
                    });
                    _scrollToChip(index);
                  },
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final routeData = routes[index] as Map<String, dynamic>;
                    final routeName = routeData['name'] ?? 'Unknown Route';
                    final stops = List<String>.from(routeData['stops'] ?? []);

                    // Find matching bus assignment for this route
                    Map<String, dynamic>? activeBus;
                    if (busesAsync is AsyncData) {
                      final buses = busesAsync.value ?? [];
                      for (final bus in buses) {
                        if (bus['route'] == routeName) {
                          activeBus = bus;
                          break;
                        }
                      }
                    }

                    final busName = activeBus?['name'] ?? 'Unassigned';
                    final busNo = activeBus?['bus_no']?.toString() ?? '—';
                    final regNumber = activeBus?['reg_number']?.toString() ?? '—';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          // Redesigned Top Info Card
                          _buildInfoCard(routeName, busNo, regNumber, busName),
                          const SizedBox(height: 32),

                          // Serpentine Timeline
                          if (stops.isNotEmpty)
                            _SerpentineTimeline(
                              stops: stops,
                              currentStopIndex: -1,
                            )
                          else
                            const Center(child: Text('No stops available for this route.')),

                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Failed to load routes.')),
      ),
    );
  }

  Widget _buildInfoCard(String routeName, String busNo, String regNumber, String busName) {
    return Container(
      decoration: AppTheme.neuBoxDecoration(radius: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Bus No Circle + Route Name & Bus Name ────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  busNo.isEmpty ? '—' : busNo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      busName.isEmpty ? 'Unassigned' : busName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 14),

          // ── Registration Number Section (Full Width, Unclipped) ──────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: AppTheme.neuBoxDecoration(radius: 14, inset: true),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, size: 16, color: AppTheme.redAccent),
                const SizedBox(width: 8),
                Text(
                  'Registration: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    regNumber.isEmpty ? '—' : regNumber,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERPENTINE TIMELINE
// ─────────────────────────────────────────────────────────────────────────────

class _SerpentineTimeline extends StatelessWidget {
  final List<String> stops;
  final int currentStopIndex;

  const _SerpentineTimeline({
    required this.stops,
    required this.currentStopIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int totalStops = stops.length;

        const int rowStops = 3;
        const double rowHeight = 130.0;
        const double vMargin = 40.0;
        const double hMargin = 20.0;
        const double radius = rowHeight / 2;

        final double effectiveLeft = hMargin + radius;
        final double effectiveRight = width - hMargin - radius;
        final double spacing = (effectiveRight - effectiveLeft) / (rowStops - 1);

        final int numRows = (totalStops / rowStops).ceil();
        final double height = vMargin * 2 + (numRows - 1) * rowHeight;

        Offset getCoordinates(int index) {
          int r = index ~/ rowStops;
          int c = index % rowStops;
          double x;
          if (r % 2 == 0) {
            x = effectiveLeft + c * spacing;
          } else {
            x = effectiveRight - c * spacing;
          }
          double y = vMargin + r * rowHeight;
          return Offset(x, y);
        }

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Draw Paths
              Positioned.fill(
                child: CustomPaint(
                  painter: _SerpentinePathPainter(
                    totalStops: totalStops,
                    currentStopIndex: currentStopIndex,
                    rowStops: rowStops,
                    rowHeight: rowHeight,
                    vMargin: vMargin,
                    effectiveLeft: effectiveLeft,
                    effectiveRight: effectiveRight,
                    spacing: spacing,
                    radius: radius,
                  ),
                ),
              ),

              // 2. Draw Stop Markers & Labels
              for (int i = 0; i < totalStops; i++)
                _buildStopMarker(
                  context,
                  index: i,
                  name: stops[i],
                  center: getCoordinates(i),
                  isActive: i <= currentStopIndex,
                  isStart: i == 0,
                  isEnd: i == totalStops - 1,
                  isJunction: i == currentStopIndex && i != 0 && i != totalStops - 1,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStopMarker(
    BuildContext context, {
    required int index,
    required String name,
    required Offset center,
    required bool isActive,
    required bool isStart,
    required bool isEnd,
    required bool isJunction,
  }) {
    Color ringColor = isActive ? AppTheme.redAccent.withValues(alpha: 0.2) : AppTheme.textSecondary.withValues(alpha: 0.1);
    Color dotColor = isActive ? AppTheme.redAccent : const Color(0xFF9E9E9E);
    Color innerColor = Colors.white;

    double dotSize = 16.0;
    double ringSize = 32.0;

    if (isStart || isEnd || isJunction) {
      dotSize = 20.0;
      ringSize = 44.0;
    }

    return Positioned(
      left: center.dx - 45,
      top: center.dy - ringSize / 2,
      width: 90,
      height: 100,
      child: Column(
        children: [
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              color: innerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ringColor,
                  spreadRadius: 4,
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: innerColor, width: 2),
              ),
              child: isStart
                  ? const Icon(Icons.circle, size: 8, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          if (isStart)
            Text(
              'START',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.redAccent, letterSpacing: 0.5),
            ),
          if (isEnd)
            Text(
              'DESTINATION',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
            ),
          if (isJunction)
            Text(
              'CURRENT STOP',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5),
            ),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: (isStart || isEnd || isJunction) ? FontWeight.bold : FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SerpentinePathPainter extends CustomPainter {
  final int totalStops;
  final int currentStopIndex;
  final int rowStops;
  final double rowHeight;
  final double vMargin;
  final double effectiveLeft;
  final double effectiveRight;
  final double spacing;
  final double radius;

  _SerpentinePathPainter({
    required this.totalStops,
    required this.currentStopIndex,
    required this.rowStops,
    required this.rowHeight,
    required this.vMargin,
    required this.effectiveLeft,
    required this.effectiveRight,
    required this.spacing,
    required this.radius,
  });

  Path _buildPathUpTo(int maxIndex) {
    Path path = Path();
    if (maxIndex < 0) return path;

    path.moveTo(effectiveLeft, vMargin);
    if (maxIndex == 0) return path;

    int maxRow = maxIndex ~/ rowStops;

    for (int r = 0; r <= maxRow; r++) {
      double y = vMargin + r * rowHeight;
      bool isLastRow = (r == maxRow);

      if (r % 2 == 0) {
        if (isLastRow) {
          int c = maxIndex % rowStops;
          path.lineTo(effectiveLeft + c * spacing, y);
        } else {
          path.lineTo(effectiveRight, y);
          path.arcToPoint(
            Offset(effectiveRight, y + rowHeight),
            radius: Radius.circular(radius),
            clockwise: true,
          );
        }
      } else {
        if (isLastRow) {
          int c = maxIndex % rowStops;
          path.lineTo(effectiveRight - c * spacing, y);
        } else {
          path.lineTo(effectiveLeft, y);
          path.arcToPoint(
            Offset(effectiveLeft, y + rowHeight),
            radius: Radius.circular(radius),
            clockwise: false,
          );
        }
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grayPaint = Paint()
      ..color = const Color(0xFF607D8B).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Path fullPath = _buildPathUpTo(totalStops - 1);
    canvas.drawPath(fullPath, grayPaint);

    if (currentStopIndex >= 0) {
      final Paint redPaint = Paint()
        ..color = AppTheme.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      Path activePath = _buildPathUpTo(currentStopIndex);
      canvas.drawPath(activePath, redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SerpentinePathPainter oldDelegate) {
    return oldDelegate.currentStopIndex != currentStopIndex ||
           oldDelegate.totalStops != totalStops;
  }
}
