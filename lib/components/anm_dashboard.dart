import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_button.dart';

class ANMDashboard extends StatefulWidget {
  const ANMDashboard({super.key});

  @override
  State<ANMDashboard> createState() => _ANMDashboardState();
}

class _ANMDashboardState extends State<ANMDashboard> {
  String _selectedVillage = 'all';
  
  final List<String> villages = [
    'all',
    'Keshavpur', 
    'Rajapur',
    'Sultanpur',
    'Mahadevpur'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.user;
    final stats = dataProvider.dashboardStats;
    
    if (user == null) return const SizedBox.shrink();

    // Filter patients based on selected village
    final filteredPatients = _selectedVillage == 'all' 
        ? dataProvider.patients
        : dataProvider.patients.where((p) => p.village == _selectedVillage).toList();

    final pregnancyRegistrations = filteredPatients
        .where((p) => p.age >= 15 && p.age <= 45 && p.gender.name == 'female')
        .toList();

    final recentVisits = dataProvider.visits.take(3).toList();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: theme.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANM Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${user.name} • Block: ${user.village ?? "District"}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          ),
        ),
        
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Village Filter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedVillage,
                        decoration: const InputDecoration(
                          labelText: 'Select Village',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: villages.map((village) {
                          return DropdownMenuItem(
                            value: village,
                            child: Text(village == 'all' ? 'All Villages' : village),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVillage = value ?? 'all';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Apply filter - already applied through state change
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Showing data for ${_selectedVillage == 'all' ? 'all villages' : _selectedVillage}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Summary Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    title: 'Pregnancies Registered',
                    value: '${pregnancyRegistrations.length}',
                    icon: Icons.pregnant_woman,
                    color: Colors.pink,
                    subtitle: 'Active cases',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'Immunizations Due',
                    value: '${stats.upcomingVisits}',
                    icon: Icons.vaccines,
                    color: stats.upcomingVisits > 0 ? Colors.orange : Colors.green,
                    subtitle: 'This week',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'High Risk Patients',
                    value: '${stats.highRiskPatients}',
                    icon: Icons.warning,
                    color: Colors.red,
                    subtitle: 'Need attention',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'Total Patients',
                    value: '${filteredPatients.length}',
                    icon: Icons.people,
                    color: Colors.blue,
                    subtitle: _selectedVillage == 'all' ? 'All villages' : _selectedVillage,
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                title: 'ANC Registration',
                description: 'Register new pregnancy case',
                icon: Icons.pregnant_woman,
                color: Colors.pink,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                title: 'Immunization Schedule',
                description: 'Plan vaccination activities',
                icon: Icons.schedule,
                color: Colors.green,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                title: 'Village Survey',
                description: 'Conduct health survey in villages',
                icon: Icons.assignment,
                color: Colors.blue,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 32),
              
              // Recent Updates Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Updates',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showFeatureNotAvailable(context),
                    child: const Text('View All'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (recentVisits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent updates',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentVisits.map((visit) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getVisitIcon(visit.type),
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${visit.type.name} • ${visit.ashaName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(visit.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )),
              
              const SizedBox(height: 80), // Bottom padding for navigation
            ]),
          ),
        ),
      ],
    );
  }

  IconData _getVisitIcon(type) {
    // Simple icon mapping - in real app would be more sophisticated
    return Icons.medical_services;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showFeatureNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}