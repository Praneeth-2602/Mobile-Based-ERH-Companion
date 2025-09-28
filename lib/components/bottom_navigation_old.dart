import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  List<NavigationItem> _getNavigationItems(UserRole role) {
    final commonItems = [
      NavigationItem(icon: Icons.home, label: 'Home', route: '/dashboard'),
      NavigationItem(icon: Icons.people, label: 'Patients', route: '/patients'),
      NavigationItem(icon: Icons.calendar_today, label: 'Calendar', route: '/calendar'),
    ];

    if (role == UserRole.phc) {
      return [
        ...commonItems,
        NavigationItem(icon: Icons.bar_chart, label: 'Analytics', route: '/analytics'),
        NavigationItem(icon: Icons.sync, label: 'Sync', route: '/sync'),
      ];
    }

    return [
      ...commonItems,
      NavigationItem(icon: Icons.sync, label: 'Sync', route: '/sync'),
    ];
  }

  void _onItemTapped(int index, String route) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to the selected route
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) return const SizedBox.shrink();
    
    final navItems = _getNavigationItems(user.role);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;
              
              return Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(index, item.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}