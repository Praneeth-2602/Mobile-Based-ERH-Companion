import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_button.dart';

class PHCDashboard extends StatelessWidget {
  const PHCDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final user = authProvider.user;
    final stats = dataProvider.dashboardStats;
    
    if (user == null) return const SizedBox.shrink();

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
                  'PHC Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${user.name} • District: ${user.village ?? "Regional"}',
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
              // Key Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Total Patients',
                    value: '${stats.totalPatients}',
                    icon: Icons.people,
                    color: Colors.blue,
                    subtitle: 'Registered',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'Active Cases',
                    value: '${stats.activeCases}',
                    icon: Icons.medical_services,
                    color: Colors.green,
                    subtitle: 'Under treatment',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'High Risk',
                    value: '${stats.highRiskPatients}',
                    icon: Icons.warning,
                    color: Colors.red,
                    subtitle: 'Need attention',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                  StatCard(
                    title: 'ANM Workers',
                    value: '12',
                    icon: Icons.work,
                    color: Colors.purple,
                    subtitle: 'Active staff',
                    onTap: () => _showFeatureNotAvailable(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Performance Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Performance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient registrations over time',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                                    return Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 45),
                                FlSpot(1, 52),
                                FlSpot(2, 48),
                                FlSpot(3, 61),
                                FlSpot(4, 55),
                                FlSpot(5, 67),
                              ],
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor.withOpacity(0.3),
                                  theme.primaryColor,
                                ],
                              ),
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    theme.primaryColor.withOpacity(0.2),
                                    theme.primaryColor.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: theme.primaryColor,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ],
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Workforce Management
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Workforce Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showFeatureNotAvailable(context),
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWorkforceCard(
                            'ANM Workers',
                            '12',
                            '2 new this month',
                            Icons.medical_services,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWorkforceCard(
                            'ASHA Workers',
                            '28',
                            '5 active today',
                            Icons.volunteer_activism,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Administrative Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                title: 'Generate Reports',
                description: 'Monthly and quarterly health reports',
                icon: Icons.assessment,
                color: Colors.indigo,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                title: 'Resource Allocation',
                description: 'Manage medical supplies and equipment',
                icon: Icons.inventory,
                color: Colors.orange,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                title: 'Training Programs',
                description: 'Schedule training for health workers',
                icon: Icons.school,
                color: Colors.teal,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 12),
              
              CustomButton(
                title: 'Quality Assurance',
                description: 'Monitor and evaluate service quality',
                icon: Icons.verified,
                color: Colors.purple,
                onTap: () => _showFeatureNotAvailable(context),
              ),
              
              const SizedBox(height: 80), // Bottom padding for navigation
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkforceCard(
    String title,
    String count,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
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