import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../components/route_selection_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.neuBoxDecoration(radius: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.neuBoxDecoration(
                      radius: 20,
                      inset: true,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppTheme.redAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Logout Confirmation',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to log out of Vahan Mitra?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            context.go('/login');
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
                            child: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
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

    return userAsync.when(
      data: (user) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 160),
          child: Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              // Avatar Section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: AppTheme.neuBoxDecoration(radius: 80),
                    child: CircleAvatar(
                      radius: 72,
                      backgroundColor: AppTheme.neuBg,
                      backgroundImage:
                          user['image_url'] != null &&
                                  user['image_url'].toString().isNotEmpty
                              ? NetworkImage(user['image_url'])
                              : null,
                      child:
                          user['image_url'] != null &&
                                  user['image_url'].toString().isNotEmpty
                              ? null
                              : const Icon(
                                Icons.person,
                                size: 70,
                                color: AppTheme.textSecondary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user['name']?.toString() ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((user['role']?.toString() ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: AppTheme.neuBoxDecoration(
                        radius: 12,
                        inset: true,
                      ),
                      child: Text(
                        (user['role']?.toString() ?? 'Student').toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Bus Number, Bus Name, and Route Name Chips
                    Row(
                      children: [
                        Expanded(
                          child: _StatChip(
                            label: 'Bus Number',
                            value:
                                assignedBus != null
                                    ? 'BUS ${assignedBus['bus_no'] ?? '--'}'
                                    : 'Unassigned',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatChip(
                            label: 'Bus Name',
                            value:
                                assignedBus != null
                                    ? (assignedBus['name']?.toString() ?? '—')
                                    : 'Unassigned',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatChip(
                      label: 'Route Name',
                      value: defaultRoute?['name']?.toString() ?? 'Not Set',
                    ),

                    const SizedBox(height: 36),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settings & Support',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: AppTheme.neuBoxDecoration(radius: 20),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _ActionTile(
                            icon: Icons.alt_route_rounded,
                            title: 'Change Default Route',
                            onTap: () => showRouteSelectionSheet(context),
                          ),
                          _ActionTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Contact Transport Team',
                            onTap: () {},
                          ),
                          _ActionTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          _ActionTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: AppTheme.neuBoxDecoration(radius: 16),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: AppTheme.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                color: AppTheme.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Failed to load user info')),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neuBoxDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: AppTheme.neuBoxDecoration(radius: 12, inset: true),
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
