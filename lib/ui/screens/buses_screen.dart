import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../components/wave_header.dart';

class BusesScreen extends ConsumerWidget {
  const BusesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(busesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WaveHeader(height: 140, title: 'Buses'),
        Expanded(
          child: busesAsync.when(
            data: (buses) {
              return ListView.builder(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 120,
                ),
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final bus = buses[index];
                  return _BusCard(
                    busId: bus['id'],
                    name: bus['name'],
                    regNumber: bus['reg_number'] ?? 'N/A',
                    route: bus['route'],
                    currentStop: bus['current_stop'] ?? 'Unknown',
                    onTap: () {
                      context.push('/map', extra: bus);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, st) => const Center(child: Text('Failed to load buses.')),
          ),
        ),
      ],
    );
  }
}

class _BusCard extends StatelessWidget {
  final String busId;
  final String name;
  final String regNumber;
  final String route;
  final String currentStop;
  final VoidCallback onTap;

  const _BusCard({
    required this.busId,
    required this.name,
    required this.regNumber,
    required this.route,
    required this.currentStop,
    required this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background accent
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.actionBlueBg.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Bus icon + name + status pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.actionBlueBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: AppTheme.actionBlueIcon,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              regNumber,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Current Stop pill (Top Right)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentStop,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Divider(
                    color: AppTheme.textSecondary.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 14),
                  // Bottom row: route + current stop pill + map button
                  Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        route,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),


                      // Track button
                      Material(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Track',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
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
            ),
          ],
        ),
      ),
    );
  }
}
