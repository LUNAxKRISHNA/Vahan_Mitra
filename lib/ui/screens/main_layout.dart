import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import 'buses_screen.dart';
import 'profile_screen.dart';
import '../components/floating_nav_bar.dart';
import '../components/sos_components.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1;
  PageController? _pageController;

  PageController get pageController {
    _pageController ??= PageController(initialPage: _currentIndex);
    return _pageController!;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    _KeepAlivePage(child: BusesScreen()),
    _KeepAlivePage(child: HomeScreen()),
    _KeepAlivePage(child: ProfileScreen()),
  ];

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuint,
    );
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSOSDialog(context),
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: const Text(
          'SOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
