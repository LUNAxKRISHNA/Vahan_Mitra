// lib/pages/tabs/home_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/wave_clipper.dart';

//======================================================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _HomeTabHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const _QuickActionsSectionHome(),
                    const SizedBox(height: 24),
                    const _ActiveBusesSectionHome(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabHeader extends StatelessWidget {
  const _HomeTabHeader();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEEE d MMM');

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 290,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255,35,36,90), const Color.fromARGB(255,255,255,255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Campus Transit',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const Text('Smart bus tracking for your college',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const Spacer(),
                Text(timeFormat.format(now),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
                Text(dateFormat.format(now),
                    style: const TextStyle(color: Colors.white70, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSectionHome extends StatelessWidget {
  const _QuickActionsSectionHome();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _QuickActionCardHome(
            icon: Icons.directions_bus_filled,
            title: 'Track Buses',
            subtitle: 'View all campus buses in real-time',
            onTap: () {}),
        const SizedBox(height: 12),
        _QuickActionCardHome(
            icon: Icons.map,
            title: 'View Map',
            subtitle: 'Interactive campus transit map',
            onTap: () {}),
        const SizedBox(height: 12),
        _QuickActionCardHome(
            icon: Icons.person,
            title: 'My Profile',
            subtitle: 'Manage settings and view stats',
            onTap: () {}),
      ],
    );
  }
}

class _QuickActionCardHome extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCardHome(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3))
                ]),
            child: Row(children: [
              Icon(icon, color: Colors.blue.shade600, size: 30),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade600))
                  ])),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 16)
            ])));
  }
}

class _ActiveBusesSectionHome extends StatelessWidget {
  const _ActiveBusesSectionHome();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Active Buses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
            onPressed: () {},
            child: Text('View All',
                style: TextStyle(color: Colors.blue.shade700)))
      ]),
      const SizedBox(height: 8),
      const _ActiveBusCardHome()
    ]);
  }
}

class _ActiveBusCardHome extends StatelessWidget {
  const _ActiveBusCardHome();
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.directions_bus, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('Bus 101', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Live',
                    style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)))
          ]),
          Text('Main Campus - Engineering',
              style: TextStyle(color: Colors.grey.shade600)),
          const Divider(height: 24),
          Row(children: [
            Icon(Icons.location_on_outlined,
                color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 4),
            Text('Engineering Building',
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(width: 4),
            const Text('•', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            Text('3 min', style: TextStyle(color: Colors.grey.shade700)),
            const Spacer(),
            const Icon(Icons.wifi, color: Colors.green, size: 18)
          ])
        ]));
  }
}