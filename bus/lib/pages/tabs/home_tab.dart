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
      // --- BODY WAS MISSING, NOW RESTORED ---
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
      // --- FloatingActionButton is correct ---
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
                          getGreeting(),
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
    return GridView.count(
      crossAxisCount: 2, // Display 2 items per row
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true, // Important for GridView inside a SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
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

// Replace the old _QuickActionCard
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
                color: const Color(0xFF1A1A1A),
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

  static final List<Drivers> driversList = [
    Drivers(
      id: 'D1',
      name: 'Ramesh Kumar',
      phoneNumber: '+91 9876543210',
      license: 'DL-123456',
      place: 'Delhi',
      imageUrl: 'assets/images/driver1.jpg',
    ),
    Drivers(
      id: 'D2',
      name: 'Suresh Singh',
      phoneNumber: '+91 9123456780',
      license: 'DL-654321',
      place: 'Mumbai',
      imageUrl: 'assets/images/driver2.jpg',
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
          height: 220, // CORRECTED HEIGHT
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
class _DriverCarouselCard extends StatelessWidget {
  final Drivers driver;

  const _DriverCarouselCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // A bit narrower for a more vertical look
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture with status indicator
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50), // Make it a circle
                    child: Image.asset(
                      driver.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Driver details
              Text(
                driver.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                driver.place,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF555555),
                ),
              ),
              const Spacer(), // Pushes the button to the bottom
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri callUri = Uri(scheme: 'tel', path: driver.phoneNumber);
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

// SOS Countdown Dialog
class _SosCountdownDialog extends StatefulWidget {
  const _SosCountdownDialog();

  @override
  State<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  late Timer _timer;
  int _countdown = 10;
  // Make totalCountdown a state variable or a constant if it's fixed
  final int _totalCountdownDuration = 10;

  final String emergencyNumber = '+918891098650';
  String _locationMessage = "Fetching location..."; // Default message

  @override
  void initState() {
    super.initState();
    _initializeSos(); // Handles permissions and location
    _startTimer();
  }

  // New method to handle permissions and location (as provided in previous response)
  Future<void> _initializeSos() async {
    // 1. Request Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
    ].request();

    // 2. Get Location if permission is granted
    if (statuses[Permission.location] == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _locationMessage =
              "Lat: ${position.latitude}, Long: ${position.longitude}";
        });
      } catch (e) {
        setState(() {
          _locationMessage = "[Location not available]";
        });
        debugPrint('Failed to get location: $e');
      }
    } else {
       setState(() {
          _locationMessage = "[Location permission denied]";
        });
    }
  }


  String get emergencyMessageText =>
      'I am in an emergency and need help. My current location is $_locationMessage.';

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
      queryParameters: <String, String>{'body': emergencyMessageText},
    );
    try {
      await launchUrl(smsUri);
      debugPrint('SOS SMS sent successfully');
    } catch (e) {
      debugPrint('Could not launch SOS SMS: $e');
      // Show user feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS SMS: $e')),
        );
      }
    }

    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      await launchUrl(callUri);
      debugPrint('SOS call initiated successfully.');
    } catch (e) {
      debugPrint('Could not launch SOS call: $e');
      // Show user feedback
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
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50], // Light red background
                foregroundColor: Colors.red[700], // Red text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red[700]!, width: 1), // Red border
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