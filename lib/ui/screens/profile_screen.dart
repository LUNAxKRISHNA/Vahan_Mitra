import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';
import '../components/wave_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WaveHeader(
            height: 140,
            title: 'Profile',
          ),
          Expanded(
            child: userAsync.when(
              data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.surface,
                  child: Icon(Icons.person, size: 50, color: AppTheme.primaryDark),
                ),
                const SizedBox(height: 16),
                Text(
                  user['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  (user['role'] as String).toUpperCase(),
                  style: const TextStyle(color: AppTheme.textSecondary, letterSpacing: 1.2),
                ),
                const SizedBox(height: 32),
                _InfoTile(icon: Icons.map, title: 'Default Route', value: user['default_route']),
                _InfoTile(
                  icon: Icons.emergency,
                  title: 'SOS Contacts',
                  value: (user['sos_contacts'] as List).join('\n'),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _OptionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _OptionTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Contact Transport Team',
                  onTap: () {},
                ),
                _OptionTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 100), // spacing for nav bar
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const Center(child: Text('Failed to load user info')),
          ),
        ),
      ],
    ),
  );
}
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
    );
  }
}
