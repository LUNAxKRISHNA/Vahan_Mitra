// lib/pages/tabs/home_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Assuming these files exist in your project structure
import '../../models/drivers_model.dart';
import '../../widgets/wave_clipper.dart';
import '../tabs/drivers_page.dart';

//======================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // --- SOS Logic ---
  void _showSosDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return const _SosCountdownDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Column(
        children: [
          const _HomeTabHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _QuickActionsSection(),
                    const SizedBox(height: 24),
                    const _DriversSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // --- Floating SOS Button ---
      floatingActionButton: FloatingActionButton(
        onPressed: _showSosDialog,
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        tooltip: 'SOS',
        child: const Icon(Icons.sos, size: 30),
      ),
    );
  }
}

// --- Header and other sections remain the same ---

class _HomeTabHeader extends StatelessWidget {
  const _HomeTabHeader();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Afternoon,',
                          style: GoogleFonts.poppins(
                            color: Color(0xFFE0E0E0),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Vahan Mitra User',
                          style: GoogleFonts.poppins(
                            color: Color(0xFFE0E0E0),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const Spacer(),
                Text(
                  dateFormat.format(now),
<<<<<<< HEAD
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
=======
                  style: GoogleFonts.poppins(
                    color: Color(0xFFBFBFBF),
                    fontSize: 16,
                  ),
>>>>>>> 8b2ee2a97b976f6178e7cf8a68366ab4b608a552
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionCard(
              icon: Icons.map_outlined,
              label: 'Track My Bus',
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.alt_route,
              label: 'View All Routes',
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.notifications_none,
              label: 'Announcements',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
<<<<<<< HEAD
                Icon(
                  icon,
                  size: 30,
                  color: const Color.fromARGB(255, 61, 65, 38),
                ),
=======
                Icon(icon,
                    size: 30, color: Color(0xFF222526)),
>>>>>>> 8b2ee2a97b976f6178e7cf8a68366ab4b608a552
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF222526),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _DriversSection extends StatelessWidget {
  const _DriversSection();

<<<<<<< HEAD
  final List<Drivers> _driversList = const [
    Drivers(
      id: 'D1',
      name: 'Ramesh Kumar',
      phoneNumber: '+91 98765 43210',
      license: 'KL-01-2020-0012345',
      place: 'Kochi',
    ),
    Drivers(
      id: 'D2',
      name: 'Suresh Menon',
      phoneNumber: '+91 91234 56789',
      license: 'KL-07-2018-0054321',
      place: 'Thrissur',
    ),
    Drivers(
      id: 'D3',
      name: 'Anil Varma',
      phoneNumber: '+91 99887 76655',
      license: 'KL-08-2019-0098765',
      place: 'Ernakulam',
    ),
  ];

=======
>>>>>>> 8b2ee2a97b976f6178e7cf8a68366ab4b608a552
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Our Drivers',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriversPage()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF1A1A1A)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: driversList.length > 3 ? 3 : driversList.length, // Show max 3 drivers
            itemBuilder: (context, index) {
              return _DriverCarouselCard(driver: driversList[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _DriverCarouselCard extends StatelessWidget {
  final Drivers driver;
  const _DriverCarouselCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A1A1A),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              driver.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
=======
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFFE0E0E0),
                backgroundImage: AssetImage(driver.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  driver.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFE0E0E0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
>>>>>>> 8b2ee2a97b976f6178e7cf8a68366ab4b608a552
          ),
          const Spacer(),
          _buildDriverDetailRow(
            icon: Icons.phone_outlined,
            text: driver.phoneNumber,
          ),
          const SizedBox(height: 8),
          _buildDriverDetailRow(
            icon: Icons.badge_outlined,
            text: driver.license,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFE0E0E0), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
<<<<<<< HEAD
=======


// --- New Widget for the SOS Countdown Dialog ---
class _SosCountdownDialog extends StatefulWidget {
  const _SosCountdownDialog();

  @override
  State<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  late Timer _timer;
  int _countdown = 10;

  final String emergencyNumber = '+918891098650'; 
  final String emergencyMessage = 'I am in an emergency and need help. My current location is [Your Location].'; 
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        if(mounted) {
          Navigator.of(context).pop(); // Close the dialog
          _triggerSosActions();
        }
      } else {
        if(mounted){
          setState(() {
            _countdown--;
          });
        }
      }
    });
  }

  Future<void> _triggerSosActions() async {
    // Action 1: Send SMS
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: {'body': emergencyMessage},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }

    // Action 2: Make a Phone Call (add a small delay)
    await Future.delayed(const Duration(seconds: 2));
    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Important to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('SOS Confirmation', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sending alert in...',
            style: TextStyle(color: Color(0xFFBFBFBF)),
          ),
          const SizedBox(height: 16),
          Text(
            '$_countdown',
            style: GoogleFonts.poppins(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'An SMS and a call will be made to your emergency contact.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
>>>>>>> 8b2ee2a97b976f6178e7cf8a68366ab4b608a552
