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

  // --- SOS Countdown Dialog ---
  // ignore: non_constant_identifier_names
  Future<void> _triggerSosActions() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{
        'body': emergencyMessage
      },
    );

    try {
      await launchUrl(smsUri);
      debugPrint('SOS SMS sent successfully');
    } catch (e) {
      debugPrint('Could not launch SOS SMS: $e');
    }

    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      await launchUrl(callUri);
      debugPrint('SOS call initiated successfully.');
    } catch (e) {
      debugPrint('Could not launch SOS call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: const Column(
        children: [
          _HomeTabHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuickActionsSection(),
                    SizedBox(height: 24),
                    _DriversSection(),
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
                            color: const Color(0xFFE0E0E0),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Vahan Mitra User',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE0E0E0),
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
                  style: GoogleFonts.poppins(
<<<<<<< HEAD
    color: const Color(0xFFBFBFBF),
    fontSize: 16,
  ),
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
        )
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon,
<<<<<<< HEAD
                    size: 30, color: const Color(0xFF222526)),
Icon(icon,
    size: 30, color: const Color(0xFF222526)),
const SizedBox(height: 8),
Text(
  label,
  textAlign: TextAlign.center,
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
class _DriversSection extends StatelessWidget {
  const _DriversSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
}

class _SosCountdownDialog extends StatefulWidget {
  const _SosCountdownDialog({Key? key}) : super(key: key);

  @override
  _SosCountdownDialogState createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  late Timer _timer;
  int _countdown = 10;

  final String emergencyNumber = '+918891098650';
  final String emergencyMessage =
      'I am in an emergency and need help. My current location is [Your Location].';
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop(); // Close the dialog
          _triggerSosActions();
        }
      } else {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      }
    });
  }

  Future<void> _triggerSosActions() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{'body': emergencyMessage},
    );

    try {
      await launchUrl(smsUri);
      debugPrint('SOS SMS sent successfully');
    } catch (e) {
      debugPrint('Could not launch SOS SMS: $e');
    }

    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      await launchUrl(callUri);
      debugPrint('SOS call initiated successfully.');
    } catch (e) {
      debugPrint('Could not launch SOS call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SOS Alert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Sending an SOS alert in:'), // Removed GoogleFonts.poppins here
          Text(
            '$_countdown seconds',
            style: const TextStyle(
                fontSize:
                    24), // Removed GoogleFonts.poppins and applied TextStyle directly
          ),
          const SizedBox(height: 16),
          const Text(
              'Your emergency contacts will be notified along with your current location.'), // Removed GoogleFonts.poppins here
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer.cancel();
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'), // Removed GoogleFonts.poppins here
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class _DriverCarouselCard extends StatelessWidget {
  final Drivers driver;
  const _DriverCarouselCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1A1A1A),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
<<<<<<< HEAD
                backgroundColor: const Color(0xFFE0E0E0),
=======
                backgroundColor: Colors.white,
>>>>>>> e06fcf9c8eb2f70211f71e070bcb336e616f83bf
                backgroundImage: AssetImage(driver.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  driver.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
<<<<<<< HEAD
                    color: const Color(0xFFE0E0E0),
=======
                    color: Colors.white,
>>>>>>> e06fcf9c8eb2f70211f71e070bcb336e616f83bf
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
CircleAvatar(
  radius: 25,
  backgroundColor: const Color(0xFFE0E0E0),
  backgroundImage: AssetImage(driver.imageUrl),
),
const SizedBox(width: 12),
Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: const Color(0xFFE0E0E0),
      ),
      overflow: TextOverflow.ellipsis,
    ),
  ),
],
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
    );
  }
}
