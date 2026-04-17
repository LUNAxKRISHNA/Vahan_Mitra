import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 70.0;
    final double totalHeight = navBarHeight + MediaQuery.of(context).padding.bottom;
    
    return Container(
      width: double.infinity,
      height: totalHeight + 40, // Height including the fade area
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Gradient Fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.background.withValues(alpha: 0.0),
                      AppTheme.background.withValues(alpha: 0.85),
                      AppTheme.background,
                    ],
                    stops: const [0.0, 0.45, 0.8],
                  ),
                ),
              ),
            ),
          ),
          // Nav Bar
          Container(
            width: double.infinity,
            height: totalHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double pillWidth = constraints.maxWidth / 3;
                        return Stack(
                          children: [
                            // Indicator
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuint,
                              left: currentIndex * pillWidth,
                              top: 12,
                              bottom: 12,
                              width: pillWidth,
                              child: Center(
                                child: Container(
                                  width: pillWidth * 0.75,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            // Items
                            Row(
                              children: [
                                _NavBarItem(
                                  icon: Icons.directions_bus_rounded,
                                  label: 'Buses',
                                  isSelected: currentIndex == 0,
                                  onTap: () => onTap(0),
                                ),
                                _NavBarItem(
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  isSelected: currentIndex == 1,
                                  onTap: () => onTap(1),
                                ),
                                _NavBarItem(
                                  icon: Icons.person_rounded,
                                  label: 'Profile',
                                  isSelected: currentIndex == 2,
                                  onTap: () => onTap(2),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(label),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



