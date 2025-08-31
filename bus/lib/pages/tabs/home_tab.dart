  // lib/pages/tabs/home_tab.dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/intl.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:permission_handler/permission_handler.dart';
  import '../../models/drivers_model.dart';
  import '../../widgets/wave_clipper.dart';

  //======================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  void _showSosDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const _SosCountdownDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HomeTabHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                  const _QuickActionsSection(),
                  const SizedBox(height: 24),
                  const _DriversSection(),
                ],
              ),
            ),
          ],
        ),
      ),
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

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning,';
  }
  if (hour < 17) {
    return 'Good Afternoon,';
  }
  return 'Good Evening,';
}

class _HomeTabHeader extends StatelessWidget {
  const _HomeTabHeader();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    const Color primaryColor = Color(0xFF0D47A1);

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                          getGreeting(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Vahan Mitra User',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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
                    color: Colors.white.withOpacity(0.9),
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
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _QuickActionCard(
          icon: Icons.directions_bus_filled,
          label: 'Track Bus',
          onTap: () {},
        ),
        _QuickActionCard(
          icon: Icons.alt_route,
          label: 'View All Routes',
          onTap: () {},
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
    const Color primaryColor = Color(0xFF0D47A1);

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriversSection extends StatelessWidget {
  const _DriversSection();

  // CHANGED: Added 'allocatedBus' to the mock data.
  // NOTE: You would also need to add this field to your 'Drivers' model class.
  static final List<Drivers> driversList = [
    const Drivers(
      id: 'D1',
      name: 'Ramesh Kumar',
      phoneNumber: '+91 9876543210',
      license: 'DL-123456',
      place: 'Delhi',
      allocatedBus: 'Bus 101',
    ),
    const Drivers(
      id: 'D2',
      name: 'Suresh Singh',
      phoneNumber: '+91 9123456780',
      license: 'DL-654321',
      place: 'Mumbai',
      allocatedBus: 'Bus 102',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drivers',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: driversList.length,
            itemBuilder: (context, index) {
              return _DriverCarouselCard(driver: driversList[index]);
            },
          ),
        ),
      ],
    );
  }
}

// =======================================================================
// --- REDESIGNED DRIVER CARD ---
// =======================================================================
class _DriverCarouselCard extends StatelessWidget {
  final Drivers driver;

  const _DriverCarouselCard({required this.driver});

  // Helper widget for info rows to avoid repetition
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D47A1);

    return Container(
      width: 280, // Made card wider for more text
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Divider(height: 20),
              _buildInfoRow(
                icon: Icons.directions_bus,
                text: 'Bus: ${driver.allocatedBus}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.badge_outlined,
                text: 'License: ${driver.license}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                text: 'Place: ${driver.place}',
              ),
              const Spacer(), // Pushes the button to the bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri callUri =
                        Uri(scheme: 'tel', path: driver.phoneNumber);
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// NOTE: The _SosCountdownDialog remains unchanged
class _SosCountdownDialog extends StatefulWidget {
  const _SosCountdownDialog();

  @override
  State<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  late Timer _timer;
  int _countdown = 10;
  final int _totalCountdownDuration = 10;

  final String emergencyNumber = '+918891098650';
  String _locationMessage = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _initializeSos();
    _startTimer();
  }

  Future<void> _initializeSos() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
    ].request();

    if (statuses[Permission.location] == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _locationMessage =
                "Lat: ${position.latitude}, Long: ${position.longitude}";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _locationMessage = "[Location not available]";
          });
        }
        debugPrint('Failed to get location: $e');
      }
    } else {
      if (mounted) {
        setState(() {
          _locationMessage = "[Location permission denied]";
        });
      }
    }
  }

  String get emergencyMessageText =>
      'I am in an emergency and need help. My current location is $_locationMessage.';

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
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
      queryParameters: <String, String>{'body': emergencyMessageText},
    );
    try {
      await launchUrl(smsUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS SMS: $e')),
        );
      }
    }

    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      await launchUrl(callUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate SOS call: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          'SOS Alert',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sending an SOS alert in:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _countdown / _totalCountdownDuration,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                  backgroundColor: Colors.red[100],
                  strokeWidth: 8,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_countdown',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'seconds',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _timer.cancel();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red[700]!, width: 1),
                ),
                elevation: 0,
              ),
              child: Text(
                'Cancel SOS',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}