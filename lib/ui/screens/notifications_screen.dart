import 'package:flutter/material.dart';
import '../components/wave_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WaveHeader(height: 140, title: 'Notifications'),
        const Expanded(child: Center(child: Text('Notifications'))),
      ],
    );
  }
}
