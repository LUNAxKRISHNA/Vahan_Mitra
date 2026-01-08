import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/config_service.dart';
import '../auth/login_page.dart';

//======================================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data is now fetched from ConfigService in build method

  @override
  Widget build(BuildContext context) {
    final userConfig = ConfigService().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _ProfilePageHeader(userConfig: userConfig),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _BusAllocationCard(
                      route: userConfig['allocatedRoute'] ?? 'N/A',
                      bus: userConfig['allocatedBus'] ?? 'N/A',
                    ),
                    const SizedBox(height: 16),
                    _FeeDetailsCard(
                      rate: userConfig['feeRate'] ?? 'N/A',
                      isPaid: userConfig['isFeePaid'] ?? false,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade400,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

// --- Header Widget (Updated to Fall Header Style) ---
class _ProfilePageHeader extends StatelessWidget {
  final Map<String, dynamic> userConfig;
  const _ProfilePageHeader({required this.userConfig});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(ConfigService().getColor('primary_color'));

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/header_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    userConfig['profileImageUrl'] ?? 'assets/logo.png',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userConfig['name'] ?? 'User',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userConfig['email'] ?? '',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Reg No: ${userConfig['regNo'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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

// --- Bus Allocation Info Card ---
class _BusAllocationCard extends StatelessWidget {
  final String route;
  final String bus;
  const _BusAllocationCard({required this.route, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.directions_bus,
              title: 'Bus Allocation',
            ),
            const SizedBox(height: 20),
            _buildInfoRow(label: 'Allocated Route', value: route),
            const Divider(height: 32),
            _buildInfoRow(label: 'Allocated Bus', value: bus),
          ],
        ),
      ),
    );
  }
}

// --- Fee Details Info Card ---
class _FeeDetailsCard extends StatelessWidget {
  final String rate;
  final bool isPaid;
  const _FeeDetailsCard({required this.rate, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final statusColor = isPaid ? Colors.green.shade600 : Colors.orange.shade600;
    final statusText = isPaid ? 'Paid' : 'Pending';

    return Card(
      color: const Color(0xFFE3F2FD),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(icon: Icons.receipt_long, title: 'Fee Details'),
            const SizedBox(height: 16),
            _buildInfoRow(label: 'Fee Rate', value: rate),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Status',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets (Updated for Light Theme) ---
Widget _buildSectionTitle({required IconData icon, required String title}) {
  final Color primaryColor = const Color(0xFF0D47A1); // Primary theme color
  return Row(
    children: [
      // CHANGED: Using primary color for icon
      Icon(icon, color: primaryColor),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _buildInfoRow({required String label, required String value}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    ],
  );
}
