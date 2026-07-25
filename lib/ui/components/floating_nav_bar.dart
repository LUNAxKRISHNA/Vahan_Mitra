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
    const double navBarHeight = 72.0;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          height: navBarHeight,
          decoration: AppTheme.neuBoxDecoration(radius: 36),
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
                    top: 10,
                    bottom: 10,
                    width: pillWidth,
                    child: Center(
                      child: Container(
                        width: pillWidth - 16,
                        decoration: BoxDecoration(
                          color: AppTheme.redAccent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.redAccent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
              color: isSelected ? Colors.white : AppTheme.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : AppTheme.textSecondary.withValues(alpha: 0.7),
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
