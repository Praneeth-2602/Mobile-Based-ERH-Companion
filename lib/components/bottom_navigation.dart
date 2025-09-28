import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<NavigationItem> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.asha:
        return [
          NavigationItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/dashboard',
            color: AppTheme.ashaColor,
          ),
          NavigationItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Patients',
            route: '/patients',
            color: AppTheme.ashaColor,
          ),
          NavigationItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Calendar',
            route: '/calendar',
            color: AppTheme.ashaColor,
          ),
          NavigationItem(
            icon: Icons.sync_outlined,
            activeIcon: Icons.sync_rounded,
            label: 'Sync',
            route: '/sync',
            color: AppTheme.ashaColor,
          ),
        ];
      case UserRole.anm:
        return [
          NavigationItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/dashboard',
            color: AppTheme.anmColor,
          ),
          NavigationItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Patients',
            route: '/patients',
            color: AppTheme.anmColor,
          ),
          NavigationItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Calendar',
            route: '/calendar',
            color: AppTheme.anmColor,
          ),
          NavigationItem(
            icon: Icons.pregnant_woman_outlined,
            activeIcon: Icons.pregnant_woman_rounded,
            label: 'Pregnancy',
            route: '/pregnancy',
            color: AppTheme.anmColor,
          ),
          NavigationItem(
            icon: Icons.sync_outlined,
            activeIcon: Icons.sync_rounded,
            label: 'Sync',
            route: '/sync',
            color: AppTheme.anmColor,
          ),
        ];
      case UserRole.phc:
        return [
          NavigationItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/dashboard',
            color: AppTheme.phcColor,
          ),
          NavigationItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Patients',
            route: '/patients',
            color: AppTheme.phcColor,
          ),
          NavigationItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            label: 'Analytics',
            route: '/analytics',
            color: AppTheme.phcColor,
          ),
          NavigationItem(
            icon: Icons.group_work_outlined,
            activeIcon: Icons.group_work_rounded,
            label: 'Workforce',
            route: '/workforce',
            color: AppTheme.phcColor,
          ),
          NavigationItem(
            icon: Icons.sync_outlined,
            activeIcon: Icons.sync_rounded,
            label: 'Sync',
            route: '/sync',
            color: AppTheme.phcColor,
          ),
        ];
    }
  }

  void _onItemTapped(int index, NavigationItem item) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      // Show feature not available for now (except dashboard)
      if (item.route != '/dashboard') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('${item.label} feature coming soon!'),
              ],
            ),
            backgroundColor: AppTheme.warningAmber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) return const SizedBox.shrink();
    
    final items = _getNavigationItems(user.role);
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = _currentIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(index, item),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive && _animationController.isAnimating
                        ? 1.1 - (_animationController.value * 0.1)
                        : 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isActive ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            item.color.withOpacity(0.15),
                            item.color.withOpacity(0.08),
                          ],
                        ) : null,
                        borderRadius: BorderRadius.circular(16),
                        border: isActive ? Border.all(
                          color: item.color.withOpacity(0.3),
                          width: 1,
                        ) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              key: ValueKey(isActive),
                              color: isActive 
                                  ? item.color 
                                  : AppTheme.neutralGray.withOpacity(0.6),
                              size: isActive ? 26 : 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isActive ? 12 : 11,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive 
                                  ? item.color 
                                  : AppTheme.neutralGray.withOpacity(0.7),
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.color,
  });
}