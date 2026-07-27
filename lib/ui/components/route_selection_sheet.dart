import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';

Future<void> showRouteSelectionSheet(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _RouteSelectionSheetContent(),
  );
}

class _RouteSelectionSheetContent extends ConsumerStatefulWidget {
  const _RouteSelectionSheetContent();

  @override
  ConsumerState<_RouteSelectionSheetContent> createState() => _RouteSelectionSheetContentState();
}

class _RouteSelectionSheetContentState extends ConsumerState<_RouteSelectionSheetContent> {
  String? _selectedRouteName;

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routesProvider);
    final busesAsync = ref.watch(busesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.neuBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Text(
            'Select Your Route',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your default bus route to quick-track it from the home screen.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Content
          routesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Failed to load routes: $e')),
            data: (routes) {
              if (routes.isEmpty) {
                return const Center(child: Text('No routes available.'));
              }

              // Create a list of route names
              final routeNames = routes.map((r) => r['name'] as String).toList();

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: AppTheme.neuBoxDecoration(radius: 16, inset: true),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRouteName,
                        hint: Text(
                          'Select a route...',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary),
                        ),
                        isExpanded: true,
                        dropdownColor: AppTheme.neuBg,
                        borderRadius: BorderRadius.circular(16),
                        icon: const Icon(Icons.expand_more_rounded, color: AppTheme.textPrimary),
                        items: routeNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedRouteName = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedRouteName != null) ...[
                    // Show assigned bus preview
                    busesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const SizedBox(),
                      data: (buses) {
                        Map<String, dynamic>? assignedBus;
                        for (var item in buses) {
                          final b = Map<String, dynamic>.from(item as Map);
                          final bRoute = (b['route'] ?? '').toString().trim().toLowerCase();
                          final selRoute = (_selectedRouteName ?? '').toString().trim().toLowerCase();
                          if (bRoute == selRoute || bRoute.contains(selRoute) || selRoute.contains(bRoute)) {
                            assignedBus = b;
                            break;
                          }
                        }

                        if (assignedBus == null) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No bus is currently assigned to this route.',
                                    style: GoogleFonts.inter(color: Colors.orange[800], fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return _BusPreviewCard(bus: assignedBus);
                      },
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRouteName == null
                  ? null
                  : () async {
                      Map<String, dynamic>? selectedRoute;
                      final routes = routesAsync.asData?.value ?? [];
                      for (var r in routes) {
                        final map = Map<String, dynamic>.from(r as Map);
                        if (map['name']?.toString() == _selectedRouteName) {
                          selectedRoute = map;
                          break;
                        }
                      }
                      selectedRoute ??= {'name': _selectedRouteName};

                      await ref.read(defaultRouteProvider.notifier).setDefaultRoute(selectedRoute);
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Confirm & Set Default',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusPreviewCard extends StatelessWidget {
  final Map<String, dynamic> bus;

  const _BusPreviewCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final busNo = bus['bus_no']?.toString() ?? '—';
    final regNo = bus['reg_number']?.toString() ?? '—';
    final driver = bus['driver_name']?.toString() ?? 'Unassigned';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neuBoxDecoration(radius: 16, inset: true),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.neuBoxDecoration(radius: 12),
            child: const Icon(Icons.directions_bus_rounded, color: AppTheme.redAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bus $busNo',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        regNo,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Driver: $driver',
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
    );
  }
}
