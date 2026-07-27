import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../components/route_selection_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasPromptedRoute = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final defaultRouteAsync = ref.watch(defaultRouteProvider);
    final nowAsync = ref.watch(currentTimeProvider);
    final now = nowAsync.asData?.value ?? DateTime.now();
    final hasUnseen = ref.watch(unseenNotificationsProvider).value ?? false;

    // Trigger onboarding bottom sheet if no default route
    if (!defaultRouteAsync.isLoading && !_hasPromptedRoute) {
      final defaultRoute = defaultRouteAsync.asData?.value;
      if (defaultRoute == null) {
        _hasPromptedRoute = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showRouteSelectionSheet(context);
        });
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 160),
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
                        title: 'All Buses',
                        subtitle: 'View list of all buses.',
                        onTap: () => context.push('/buses'),
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
                        subtitle: "View College Bus Timings.",
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.4),
                            builder:
                                (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 28,
                                    ),
                                    decoration: AppTheme.neuBoxDecoration(
                                      radius: 28,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme.redAccent
                                                .withValues(alpha: 0.1),
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 28,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                        hasBadge: hasUnseen,
                        onTap: () => context.push('/notifications'),
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
    final defaultRouteAsync = ref.watch(defaultRouteProvider);
    final busesAsync = ref.watch(busesProvider);

    final defaultRoute = defaultRouteAsync.asData?.value;
    final buses = busesAsync.asData?.value ?? [];

    Map<String, dynamic>? assignedBus;
    if (defaultRoute != null) {
      final selRoute =
          (defaultRoute['name'] ?? '').toString().trim().toLowerCase();
      for (var item in buses) {
        final b = Map<String, dynamic>.from(item as Map);
        final bRoute = (b['route'] ?? '').toString().trim().toLowerCase();
        if (bRoute == selRoute ||
            bRoute.contains(selRoute) ||
            selRoute.contains(bRoute)) {
          assignedBus = b;
          break;
        }
      }
    }

    final bool hasDefaultRoute = defaultRoute != null;
    final bool isLive =
        assignedBus != null &&
        ((assignedBus['status'] as String? ?? '').toLowerCase() == 'running' ||
            (assignedBus['status'] as String? ?? '').toLowerCase() ==
                'in transit');

    final String cardTitle =
        assignedBus != null
            ? (assignedBus['name']?.toString() ??
                'Bus ${assignedBus['bus_no'] ?? ''}')
            : (hasDefaultRoute
                ? (defaultRoute['name']?.toString() ?? 'Default Route')
                : 'Setup Default Route');

    final String cardSubtitle =
        assignedBus != null
            ? (assignedBus['route']?.toString() ??
                defaultRoute?['name']?.toString() ??
                'Assigned Route')
            : (hasDefaultRoute
                ? 'Assigned Daily Route'
                : 'Tap here to select your daily route.');

    return GestureDetector(
      onTap: () {
        if (assignedBus != null) {
          context.push('/map', extra: assignedBus);
        } else if (hasDefaultRoute) {
          context.push('/map');
        } else {
          showRouteSelectionSheet(context);
        }
      },
      child: Container(
        decoration: AppTheme.neuBoxDecoration(radius: 28),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Semi-transparent side-filled Bus Number Watermark (Top Right)
            if (assignedBus != null)
              Positioned(
                right: -1,
                top: -10,
                child: Text(
                  '${assignedBus['bus_no'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 100,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary.withValues(alpha: 0.08),
                    height: 1.1,
                    letterSpacing: -2,
                  ),
                ),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Status Row: Live Status (Left)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasDefaultRoute)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Live Status Indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  isLive
                                      ? const Color(0xFF2B8A3E)
                                      : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLive
                                ? 'In Transit'
                                : (assignedBus != null
                                    ? 'Offline'
                                    : 'Assigned'),
                            style: GoogleFonts.inter(
                              color:
                                  isLive
                                      ? const Color(0xFF2B8A3E)
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(),
                  ],
                ),
                const SizedBox(height: 14),

                // Real Bus Name as Title
                Text(
                  cardTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Route Name as Subtitle
                Text(
                  cardSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 22),

                // Driver Info & Bottom "Track Bus" Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (assignedBus != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppTheme.neuBoxDecoration(
                          radius: 12,
                          inset: true,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: AppTheme.redAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            assignedBus['driver_name']?.toString() ?? 'Unknown',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),

                    // Bottom "Track Bus" Black Pill Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Track Bus',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasBadge;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasBadge = false,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppTheme.neuBoxDecoration(
                    radius: 12,
                    inset: true,
                  ),
                  child: Icon(icon, color: AppTheme.textPrimary, size: 24),
                ),
                if (hasBadge)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
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
