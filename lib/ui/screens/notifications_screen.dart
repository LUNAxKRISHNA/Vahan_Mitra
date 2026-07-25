import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../controllers/mock_data_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as read after building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markAllAsRead();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationsProvider.notifier).refresh();
    ref.read(notificationsProvider.notifier).markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.neuBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppTheme.neuBoxDecoration(radius: 12),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Alerts',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.redAccent,
                backgroundColor: AppTheme.neuBg,
                strokeWidth: 2.5,
                displacement: 25,
                child: notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final alert = Map<String, dynamic>.from(notifications[index]);
                        final rawTime = alert['time']?.toString() ?? alert['created_at']?.toString() ?? alert['sent_at']?.toString();
                        return _AlertCard(
                          title: alert['msg_title']?.toString() ?? alert['title']?.toString() ?? 'Alert',
                          message: alert['msg_content']?.toString() ?? alert['content']?.toString() ?? '',
                          timeString: rawTime,
                          onTap: () => _showNotificationDetailDialog(context, alert),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.redAccent),
                  ),
                  error: (error, stack) => _buildEmptyState(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetailDialog(BuildContext context, Map<String, dynamic> alert) {
    final title = alert['msg_title']?.toString() ?? alert['title']?.toString() ?? 'Alert Detail';
    final content = alert['msg_content']?.toString() ?? alert['content']?.toString() ?? alert['message']?.toString() ?? 'No content available.';
    final rawTime = alert['time']?.toString() ?? alert['created_at']?.toString() ?? alert['sent_at']?.toString();

    // Resolve person name and designation/role from admin relational join or fallback fields
    String sentBy = 'Transport Admin';
    String role = '';
    
    final adminObj = alert['admin'];
    Map<String, dynamic>? adminMap;
    
    if (adminObj is Map<String, dynamic>) {
      adminMap = adminObj;
    } else if (adminObj is List && adminObj.isNotEmpty && adminObj.first is Map) {
      adminMap = adminObj.first as Map<String, dynamic>;
    }

    if (adminMap != null) {
      sentBy = adminMap['name']?.toString() ?? 
               adminMap['full_name']?.toString() ?? 
               adminMap['username']?.toString() ?? 
               'Transport Admin';
      role = adminMap['role']?.toString() ?? adminMap['designation']?.toString() ?? '';
    } else if (alert['sender_name'] != null && alert['sender_name'].toString().isNotEmpty) {
      sentBy = alert['sender_name'].toString();
      role = alert['role']?.toString() ?? alert['designation']?.toString() ?? '';
    } else if (alert['admin_name'] != null && alert['admin_name'].toString().isNotEmpty) {
      sentBy = alert['admin_name'].toString();
      role = alert['role']?.toString() ?? '';
    } else if (alert['sent_by'] != null) {
      final rawSentBy = alert['sent_by'].toString();
      if (!rawSentBy.contains('-') && rawSentBy.length <= 20) {
        sentBy = rawSentBy;
      }
    }

    String formattedTime = 'N/A';
    if (rawTime != null && rawTime.isNotEmpty) {
      final parsed = DateTime.tryParse(rawTime);
      if (parsed != null) {
        formattedTime = DateFormat('MMM dd, yyyy • hh:mm a').format(parsed.toLocal());
      } else {
        formattedTime = rawTime;
      }
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.neuBoxDecoration(radius: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.redAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: AppTheme.redAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              Divider(color: Colors.grey.withValues(alpha: 0.2)),
              const SizedBox(height: 12),

              // Message Content
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Metadata Box (Time, Sent By & Designation)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.neuBoxDecoration(radius: 16, inset: true),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Sent Time: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Sent By: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            sentBy,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Designation: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              role,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.redAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.redAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_rounded,
                    size: 48,
                    color: AppTheme.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No new messages',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "There are no alerts at this time.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String? timeString;
  final VoidCallback onTap;

  const _AlertCard({
    required this.title,
    required this.message,
    required this.onTap,
    this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    final displayTime = _getFormattedTime(timeString);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.neuBoxDecoration(radius: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.neuBoxDecoration(radius: 14, inset: true),
              child: const Icon(
                Icons.campaign_rounded,
                color: AppTheme.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (displayTime.isNotEmpty)
                        Text(
                          displayTime,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      final localDt = dt.toLocal();
      final now = DateTime.now();
      final diff = now.difference(localDt);
      
      if (diff.inDays == 0 && now.day == localDt.day) {
        return DateFormat.jm().format(localDt); // e.g., 5:30 PM
      } else if (diff.inDays < 7) {
        return DateFormat.E().format(localDt); // e.g., Mon
      } else {
        return DateFormat.MMMd().format(localDt); // e.g., Oct 12
      }
    }
    return raw; // If it's a string value like "10:30 AM" or "Just now"
  }
}
