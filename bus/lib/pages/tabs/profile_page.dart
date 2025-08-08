import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/wave_clipper.dart';
import '../auth/login_page.dart';

class StudentProfile {
  final String name;
  final String regNo;
  final String email;
  final String profileImageUrl;
  final String allocatedRoute;
  final String allocatedBus;
  final String feeRate;
  final bool isFeePaid;

  const StudentProfile({
    required this.name,
    required this.regNo,
    required this.email,
    required this.profileImageUrl,
    required this.allocatedRoute,
    required this.allocatedBus,
    required this.feeRate,
    required this.isFeePaid,
  });
}

//======================================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _studentProfile = const StudentProfile(
    name: 'Priya Chauhan',
    regNo: '29114567',
    email: 'priya.chauhan@cvv.ac.in',
    profileImageUrl: 'assets/logo.png', 
    allocatedRoute: 'Main Campus - Engineering',
    allocatedBus: 'Bus 101',
    feeRate: '₹5,000 / Month',
    isFeePaid: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Column(
        children: [
          _ProfilePageHeader(student: _studentProfile),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _BusAllocationCard(
                      route: _studentProfile.allocatedRoute,
                      bus: _studentProfile.allocatedBus,
                    ),
                    const SizedBox(height: 16),
                    _FeeDetailsCard(
                      rate: _studentProfile.feeRate,
                      isPaid: _studentProfile.isFeePaid,
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
                        backgroundColor: Colors.red[400],
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

// --- Header Widget ---
class _ProfilePageHeader extends StatelessWidget {
  final StudentProfile student;
  const _ProfilePageHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 240,
        width: double.infinity,
        color: const Color(0xFF1A1A1A),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFBFBFBF),
                      backgroundImage: AssetImage(student.profileImageUrl),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: GoogleFonts.poppins(
                            color: Color(0xFFBFBFBF),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.email,
                          style: const TextStyle(
                              color: Color(0xFFBFBFBF), fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFBFBF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Reg No: ${student.regNo}',
                            style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
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

// --- Bus Allocation Info Card ---
class _BusAllocationCard extends StatelessWidget {
  final String route;
  final String bus;
  const _BusAllocationCard({required this.route, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(icon: Icons.directions_bus, title: 'Bus Allocation'),
            const SizedBox(height: 16),
            _buildInfoRow(label: 'Allocated Route', value: route),
            const Divider(height: 24),
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
    final statusColor = isPaid ? Colors.green : Colors.orange;
    final statusText = isPaid ? 'Paid' : 'Pending';

    return Card(
      elevation: 2,
      shadowColor: Color(0xFF1A1A1A),
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
                Text(
                  'Payment Status',
                  style: TextStyle(color: Color(0xFF222526),fontSize: 14),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---
Widget _buildSectionTitle({required IconData icon, required String title}) {
  return Row(
    children: [
      Icon(icon, color: const Color(0xFF1A1A1A)),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget _buildInfoRow({required String label, required String value}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(color: Color(0xFF222526), fontSize: 14),
      ),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF1A1A1A),
        ),
      ),
    ],
  );
}
