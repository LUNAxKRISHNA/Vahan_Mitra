import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final nowAsync = ref.watch(currentTimeProvider);
    final now = nowAsync.asData?.value ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userAsync.when(
                    data:
                        (user) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting(now)},',
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user['name'].split(' ')[0]}',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome to Vahan Mitra',
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                    loading: () => const Text('Loading...'),
                    error: (e, st) => const Text('Error'),
                  ),
                  Row(
                    children: [
                      userAsync.when(
                        data:
                            (user) => CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.neuBg,
                              backgroundImage:
                                  user['image_url'] != null &&
                                          user['image_url']
                                              .toString()
                                              .isNotEmpty
                                      ? NetworkImage(user['image_url'])
                                      : null,
                              child:
                                  user['image_url'] == null ||
                                          user['image_url'].toString().isEmpty
                                      ? const Icon(
                                        Icons.person,
                                        color: AppTheme.textPrimary,
                                      )
                                      : null,
                            ),
                        loading: () => const CircleAvatar(radius: 24),
                        error: (e, st) => const CircleAvatar(radius: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Hero Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const _LiveTransportCard(),
          ),

          // 2x2 Action Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.directions_bus_rounded,
                        title: 'Track Buses',
                        subtitle: 'Live locations of all buses.',
                        onTap: () => context.push('/map'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.route_rounded,
                        title: 'Routes',
                        subtitle: 'View all campus routes.',
                        onTap: () => context.push('/routes'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Timetable',
                        subtitle: "Bus Schedules.",
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.4),
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                                decoration: AppTheme.neuBoxDecoration(radius: 28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.redAccent.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppTheme.redAccent,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Coming Soon',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Timetable details will be\nupdated soon.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    GestureDetector(
                                      onTap: () => Navigator.of(ctx).pop(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.redAccent,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Got it',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.campaign_rounded,
                        title: 'Alerts',
                        subtitle: 'Latest transport updates.',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }
}

class _LiveTransportCard extends ConsumerStatefulWidget {
  const _LiveTransportCard();

  @override
  ConsumerState<_LiveTransportCard> createState() => _LiveTransportCardState();
}

class _LiveTransportCardState extends ConsumerState<_LiveTransportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busesAsync = ref.watch(staticBusesProvider);
    final routesAsync = ref.watch(routesProvider);

    final buses = busesAsync.asData?.value ?? [];
    final busCount = buses.length;
    final routeCount = routesAsync.asData?.value.length ?? 0;

    // Only show LIVE badge if at least one bus is actively running
    final anyBusLive = buses.any((bus) {
      final status = (bus['status'] as String? ?? '').toLowerCase();
      return status == 'running' || status == 'in transit';
    });

    return Container(
      decoration: AppTheme.neuBoxDecoration(radius: 28),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          // Graphic Background (Right Side)
          Positioned(
            right: -20,
            top: 0,
            bottom: 0,
            width: 120,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RouteLinePainter(progress: _animController.value),
                );
              },
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LIVE Badge — only shown when buses are actively running
              if (anyBusLive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          color: AppTheme.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 16),

              Text(
                'Transport Services',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // Stats dynamically fetched from Supabase
              Row(
                children: [
                  _StatItem(
                    icon: Icons.directions_bus_rounded,
                    count: busesAsync.isLoading ? '…' : '$busCount',
                    label: 'College Buses\nOperating',
                  ),
                  const SizedBox(width: 32),
                  _StatItem(
                    icon: Icons.route_rounded,
                    count: routesAsync.isLoading ? '…' : '$routeCount',
                    label: 'Active\nRoutes',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  final double progress;

  _RouteLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppTheme.redAccent.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.8, 10);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.5,
      size.height - 10,
    );

    // Draw dashed path
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    var distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }

    // Bus position indicator
    final busPosition =
        path
            .computeMetrics()
            .first
            .extractPath(
              0,
              path.computeMetrics().first.length * (0.3 + (progress * 0.4)),
            )
            .computeMetrics()
            .last
            .getTangentForOffset(
              path.computeMetrics().first.length * (0.3 + (progress * 0.4)),
            )
            ?.position;

    if (busPosition != null) {
      final busPaint =
          Paint()
            ..color = AppTheme.textPrimary
            ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: busPosition, width: 14, height: 14),
          const Radius.circular(4),
        ),
        busPaint,
      );
    }

    // Pins
    canvas.drawCircle(
      Offset(size.width * 0.8, 10),
      6,
      Paint()..color = AppTheme.textPrimary,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height - 10),
      6,
      Paint()..color = AppTheme.redAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: AppTheme.neuBoxDecoration(radius: 12, inset: true),
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.neuBoxDecoration(radius: 20),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.neuBoxDecoration(radius: 12, inset: true),
              child: Icon(icon, color: AppTheme.textPrimary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: AppTheme.neuBoxDecoration(radius: 20),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
