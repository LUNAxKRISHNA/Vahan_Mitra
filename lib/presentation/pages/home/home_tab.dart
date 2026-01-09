import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:another_telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/services/config_service.dart';
import '../routes/routes_page.dart';

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
            const _FallHeader(),
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
                  const SizedBox(height: 20),
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

class _FallHeader extends StatelessWidget {
  const _FallHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    final userConfig = ConfigService().user;
    final userName = userConfig['name'] ?? 'User';

    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(ConfigService().getColor('primary_color')),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/header_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.4, // Dim image to ensure text readability
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(
                        userConfig['profileImageUrl'] ?? 'assets/logo.png',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(now),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
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
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _QuickActionCard(
          icon: Icons.directions_bus_filled,
          label: 'Track Bus',
          onTap: () {
            // Logic to track bus
          },
          backgroundColor: const Color(0xFFE3F2FD),
        ),
        _QuickActionCard(
          icon: Icons.alt_route,
          label: 'View All Routes',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoutesPage()),
            );
          },
          backgroundColor: const Color(0xFFE3F2FD),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(ConfigService().getColor('primary_color'));

    return Card(
      color: backgroundColor,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final driversData = ConfigService().drivers;

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
          height: 250, // Increased height to prevent overflow
          child:
              driversData.isEmpty
                  ? const Center(child: Text("No drivers found"))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: driversData.length,
                    itemBuilder: (context, index) {
                      final data = driversData[index];
                      return _DriverCarouselCard(
                        name: data['name'] ?? '',
                        allocatedBus: data['allocatedBus'] ?? '',
                        license: data['license'] ?? '',
                        place: data['place'] ?? '',
                        phoneNumber: data['phoneNumber'] ?? '',
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _DriverCarouselCard extends StatelessWidget {
  final String name;
  final String allocatedBus;
  final String license;
  final String place;
  final String phoneNumber;

  const _DriverCarouselCard({
    required this.name,
    required this.allocatedBus,
    required this.license,
    required this.place,
    required this.phoneNumber,
  });

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(ConfigService().getColor('primary_color'));

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min to adapt
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.directions_bus,
                text: 'Bus: $allocatedBus',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.badge_outlined,
                text: 'License: $license',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                text: 'Place: $place',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
                    if (await canLaunchUrl(callUri)) {
                      await launchUrl(callUri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// SOS DIALOG
// =======================================================================
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

  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _initializeSos();
    _startTimer();
  }

  Future<void> _initializeSos() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.location, Permission.phone, Permission.sms].request();

    if (statuses[Permission.location] == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _locationMessage =
                "https://maps.google.com/?q=${position.latitude},${position.longitude}";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _locationMessage = "[Location not available]";
          });
        }
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
    await _makeDirectCall();
    await _sendEmergencyMessages();
  }

  Future<void> _makeDirectCall() async {
    try {
      await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
      _showFeedback('SOS call initiated successfully.');
    } catch (e) {
      _showFeedback('Failed to make SOS call: $e', isError: true);
    }
  }

  Future<void> _sendEmergencyMessages() async {
    if (Platform.isAndroid) {
      try {
        await telephony.sendSms(
          to: emergencyNumber,
          message: emergencyMessageText,
        );
        _showFeedback('Direct SMS sent successfully.');
      } catch (e) {
        _showFeedback('Error sending direct SMS: $e', isError: true);
      }
    } else {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: emergencyNumber,
        queryParameters: {'body': Uri.encodeComponent(emergencyMessageText)},
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        _showFeedback('SMS app opened.');
      } else {
        _showFeedback('Could not open SMS app.', isError: true);
      }
    }

    // WhatsApp
    final String whatsappNumber = emergencyNumber.replaceFirst('+', '');
    final String whatsappUrl =
        "https://wa.me/$whatsappNumber/?text=${Uri.encodeComponent(emergencyMessageText)}";
    final Uri whatsappUri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      _showFeedback('WhatsApp opened.');
    } else {
      _showFeedback(
        'Could not launch WhatsApp. Is it installed?',
        isError: true,
      );
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
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
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
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
