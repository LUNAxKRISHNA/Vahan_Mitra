import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../components/wave_header.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WaveHeader(
            height: 140,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Routes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: routesAsync.when(
              data: (routes) {
                if (routes.isEmpty) {
                  return const Center(child: Text('No routes available.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 40,
                  ),
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final routeData = routes[index];
                    final stops = List<String>.from(routeData['stops'] ?? []);
                    return _RouteCard(
                      name: routeData['name'] ?? 'Unknown Route',
                      stops: stops,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('Failed to load routes.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatefulWidget {
  final String name;
  final List<String> stops;

  const _RouteCard({
    required this.name,
    required this.stops,
  });

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.actionGreenBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: AppTheme.actionGreenIcon,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.stops.length} Stops',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
            children: [
              if (widget.stops.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 36, right: 20, bottom: 20, top: 8),
                  child: _StopTimeline(stops: widget.stops),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No stops defined for this route.',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopTimeline extends StatelessWidget {
  final List<String> stops;

  const _StopTimeline({required this.stops});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stops.length, (index) {
        final isFirst = index == 0;
        final isLast = index == stops.length - 1;
        
        Color dotColor = AppTheme.primary;
        if (isFirst) {
          dotColor = AppTheme.actionGreenIcon;
        } else if (isLast) {
          dotColor = AppTheme.accent;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Top line
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.2),
                ),
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: dotColor, width: 3),
                    shape: BoxShape.circle,
                  ),
                ),
                // Bottom line
                Container(
                  width: 2,
                  height: isLast ? 0 : 36,
                  color: isLast ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  stops[index],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isFirst || isLast ? FontWeight.w600 : FontWeight.w500,
                    color: isFirst || isLast ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
