import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/sync_status.dart';
import 'patient_registration_form.dart';
import 'patient_list_screen.dart';
import 'anc_visit_form.dart';
import 'immunization_form.dart';
import '../services/cloud_sync_service.dart' as cloud;
import '../models/asha_task.dart';
import '../models/verification_issue.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      body: _buildDashboardForRole(context, user),
    );
  }

  Widget _buildDashboardForRole(BuildContext context, User user) {
    switch (user.role) {
      case UserRole.asha:
        return _ASHADashboard(user: user);
      case UserRole.anm:
        return _ANMDashboard(user: user);
      case UserRole.phc:
        return _PHCDashboard(user: user);
    }
  }
}

class _ASHADashboard extends StatelessWidget {
  final User user;
  
  const _ASHADashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final stats = dataProvider.dashboardStats;
        final reminders = dataProvider.getTodayReminders();
        
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
                    Text(
                      'Hello, ${user.name.split(' ').first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ASHA Worker • ${user.village ?? "Village"}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: [
                const SyncStatus(),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _handleLogout(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Grid
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
                        onTap: () => _navigateToPatientList(context),
                      ),
                      StatCard(
                        title: 'Visits Today',
                        value: '${stats.visitsToday}',
                        icon: Icons.calendar_today,
                        color: Colors.green,
                        subtitle: 'Completed',
                        onTap: () => _showFeatureNotAvailable(context),
                      ),
                      StatCard(
                        title: 'High Risk',
                        value: '${stats.highRiskPatients}',
                        icon: Icons.warning,
                        color: Colors.red,
                        subtitle: 'Patients',
                        onTap: () => _navigateToHighRiskPatients(context),
                      ),
                      StatCard(
                        title: 'Pending Tasks',
                        value: '${stats.pendingTasks}',
                        icon: Icons.task_alt,
                        color: Colors.orange,
                        subtitle: 'To complete',
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
                    title: 'Register New Patient',
                    description: 'Add a new patient to the system',
                    icon: Icons.person_add,
                    color: theme.primaryColor,
                    onTap: () => _navigateToPatientRegistration(context),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  CustomButton(
                    title: 'ANC Visit',
                    description: 'Record antenatal care visit',
                    icon: Icons.pregnant_woman,
                    color: Colors.pink,
                    onTap: () => _navigateToANCVisitForm(context),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  CustomButton(
                    title: 'Immunization',
                    description: 'Record vaccination details',
                    icon: Icons.vaccines,
                    color: Colors.green,
                    onTap: () => _navigateToImmunizationForm(context),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sync Status Section
                  _buildSyncSection(context, dataProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Today's Reminders
                  Text(
                    "Today's Reminders",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (reminders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No reminders for today! Great work!',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...reminders.map(
                      (reminder) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: reminder.isHighPriority 
                                ? Colors.red.shade200 
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: reminder.isHighPriority 
                                    ? Colors.red.shade100 
                                    : Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                reminder.isHighPriority
                                    ? Icons.priority_high
                                    : Icons.schedule,
                                color: reminder.isHighPriority 
                                    ? Colors.red.shade600 
                                    : Colors.blue.shade600,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${reminder.patientName} • ${reminder.description}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showFeatureNotAvailable(context),
                              child: const Text('Complete'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 80), // Bottom padding for navigation
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToPatientRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatientRegistrationForm(),
      ),
    );
  }

  void _navigateToPatientList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatientListScreen(),
      ),
    );
  }

  void _navigateToHighRiskPatients(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatientListScreen(
          initialFilter: 'high-risk',
        ),
      ),
    );
  }

  void _navigateToANCVisitForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ANCVisitForm(),
      ),
    );
  }

  void _navigateToImmunizationForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImmunizationForm(),
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

  Widget _buildSyncSection(BuildContext context, DataProvider dataProvider) {
    final theme = Theme.of(context);
    final syncCounts = dataProvider.getSyncStatusCounts();
    final lastSyncSummary = dataProvider.lastSyncSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Sync',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (dataProvider.hasConnectivity)
                  Icon(Icons.wifi, color: Colors.green.shade600, size: 20)
                else
                  Icon(Icons.wifi_off, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: dataProvider.isSyncing ? null : () => _handleManualSync(context, dataProvider),
                  icon: dataProvider.isSyncing 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(dataProvider.isSyncing ? 'Syncing...' : 'Sync Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sync status overview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSyncStatusItem(
                    context,
                    'Synced',
                    '${syncCounts[cloud.SyncStatus.synced]}',
                    Colors.green,
                    Icons.cloud_done_outlined,
                  ),
                  _buildSyncStatusItem(
                    context,
                    'Pending',
                    '${syncCounts[cloud.SyncStatus.pending]}',
                    Colors.orange,
                    Icons.cloud_upload_outlined,
                  ),
                  _buildSyncStatusItem(
                    context,
                    'Failed',
                    '${syncCounts[cloud.SyncStatus.failed]}',
                    Colors.red,
                    Icons.cloud_off_outlined,
                  ),
                ],
              ),
              if (lastSyncSummary != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Last sync: ${_formatSyncTime(lastSyncSummary.syncTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (lastSyncSummary.hasFailures) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${lastSyncSummary.failedRecords} failed, ${lastSyncSummary.conflictedRecords} conflicts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusItem(
    BuildContext context,
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _handleManualSync(BuildContext context, DataProvider dataProvider) async {
    if (!await dataProvider.checkCloudConnectivity()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your network and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final summary = await dataProvider.syncAllToCloud();
    
    if (context.mounted) {
      if (summary.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully synced ${summary.syncedRecords} records'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync completed with issues: ${summary.syncedRecords} synced, '
              '${summary.failedRecords} failed, ${summary.conflictedRecords} conflicts',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final difference = now.difference(syncTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Similar implementations for ANM and PHC dashboards with role-specific content
class _ANMDashboard extends StatelessWidget {
  final User user;
  
  const _ANMDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<DataProvider>(
      builder: (context, data, _) {
  final workers = data.ashaWorkers;
  final conflictIssues = data.getConflictIssues();
  final incompleteIssues = data.getIncompleteIssues();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.name.split(' ').first}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'ANM Supervisor',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: [
                const SyncStatus(),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _handleLogout(context),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Workforce overview
                  Text('ASHA Workforce', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...workers.map((w) => _buildAshaRow(context, w, data)),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Assign Task'),
                      onPressed: () => _openAssignTaskDialog(context, data, workers),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Data Verification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildVerificationSection(
                    context,
                    'Conflicts',
                    conflictIssues,
                    Colors.red,
                    Icons.report_gmailerrorred_outlined,
                    data,
                    user,
                    workers,
                  ),
                  const SizedBox(height: 12),
                  _buildVerificationSection(
                    context,
                    'Incomplete Records',
                    incompleteIssues,
                    Colors.orange,
                    Icons.assignment_late_outlined,
                    data,
                    user,
                    workers,
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAshaRow(BuildContext context, User w, DataProvider data) {
    final tasks = data.getTasksByAshaId(w.id);
    final pending = tasks.where((t) => t.status != TaskStatus.completed && t.status != TaskStatus.cancelled).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: w.isOnline ? Colors.green.shade100 : Colors.grey.shade200,
            child: Icon(Icons.person, color: w.isOnline ? Colors.green.shade700 : Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${w.village ?? ''} • Pending tasks: $pending', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showTasksBottomSheet(context, w, data),
            child: const Text('View Tasks'),
          ),
        ],
      ),
    );
  }

  void _showTasksBottomSheet(BuildContext context, User w, DataProvider data) {
    final tasks = data.getTasksByAshaId(w.id);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasks for ${w.name}', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (tasks.isEmpty) const Text('No tasks assigned yet')
            else ...tasks.map((t) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.title),
              subtitle: Text(t.description),
              trailing: DropdownButton<TaskStatus>(
                value: t.status,
                onChanged: (val) {
                  if (val != null) data.updateTaskStatus(t.id, val);
                },
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              ),
            )),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _openAssignTaskDialog(context, data, [w]),
                icon: const Icon(Icons.add),
                label: const Text('Assign new task'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openAssignTaskDialog(BuildContext context, DataProvider data, List<User> workers) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? dueDate;
    TaskPriority priority = TaskPriority.medium;
    User? selected = workers.isNotEmpty ? workers.first : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Priority:'),
                const SizedBox(width: 8),
                DropdownButton<TaskPriority>(
                  value: priority,
                  onChanged: (v) { if (v != null) { priority = v; (ctx as Element).markNeedsBuild(); } },
                  items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: ctx, firstDate: now, lastDate: now.add(const Duration(days: 365)), initialDate: now);
                    if (picked != null) {
                      dueDate = picked;
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                  icon: const Icon(Icons.event),
                  label: Text(dueDate == null ? 'Pick due date' : '${dueDate!.toLocal()}'.split(' ').first),
                ),
              ]),
              const SizedBox(height: 8),
              DropdownButton<User>(
                value: selected,
                isExpanded: true,
                onChanged: (u) { selected = u; (ctx as Element).markNeedsBuild(); },
                items: workers.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (selected != null && titleCtrl.text.trim().isNotEmpty) {
                data.assignTask(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  dueDate: dueDate,
                  priority: priority,
                  ashaId: selected!.id,
                  ashaName: selected!.name,
                  createdByUserId: user.id,
                  createdByName: user.name,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task assigned')));
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(
    BuildContext context,
    String title,
    List<VerificationIssue> issues,
    Color color,
    IconData icon,
    DataProvider data,
    User user,
    List<User> workers,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
  color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${issues.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (issues.isEmpty)
            Text('No ${title.toLowerCase()}')
          else
            ...issues.map(
              (issue) => _buildIssueCard(
                context,
                issue,
                data,
                user,
                workers,
                color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(
    BuildContext context,
    VerificationIssue issue,
    DataProvider data,
    User user,
    List<User> workers,
    Color accentColor,
  ) {
  final theme = Theme.of(context);
  final resolved = data.isIssueResolved(issue.id);
  final escalated = data.isIssueEscalated(issue.id);
  final severityColor = _severityColor(issue.severity);
  final resolvedBackground = theme.colorScheme.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
    color: resolved ? resolvedBackground : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: escalated ? Colors.deepOrange.shade400 : accentColor.withValues(alpha: 0.25),
          width: escalated ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                issue.type == IssueType.conflict
                    ? Icons.report_problem_outlined
                    : Icons.assignment_late_outlined,
                color: severityColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            issue.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: resolved ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        _buildSeverityChip(context, issue.severity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showIssueDetails(context, issue, data),
                icon: const Icon(Icons.info_outline),
                tooltip: 'View details',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (issue.patientName != null)
                _buildInfoChip(context, Icons.person_outline, issue.patientName!),
              if (issue.ashaName != null)
                _buildInfoChip(context, Icons.badge_outlined, 'ASHA: ${issue.ashaName}'),
              _buildInfoChip(context, Icons.schedule, _formatTimeAgo(issue.detectedAt)),
              _buildInfoChip(context, Icons.article_outlined, _recordTypeLabel(issue)),
              if (resolved)
                _buildInfoChip(context, Icons.check_circle, 'Resolved', iconColor: Colors.green.shade600),
              if (escalated)
                _buildInfoChip(context, Icons.flag, 'Escalated', iconColor: Colors.deepOrange.shade600),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (resolved) {
                    data.reopenIssue(issue.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Issue reopened')),
                    );
                  } else {
                    data.markIssueResolved(issue.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Issue marked as resolved')),
                    );
                  }
                },
                icon: Icon(resolved ? Icons.undo : Icons.check_circle_outline),
                label: Text(resolved ? 'Reopen' : 'Resolve'),
              ),
              TextButton.icon(
                onPressed: () {
                  if (escalated) {
                    data.deescalateIssue(issue.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Issue de-escalated')),
                    );
                  } else {
                    data.escalateIssue(issue.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Issue escalated')),
                    );
                  }
                },
                icon: Icon(escalated ? Icons.outlined_flag : Icons.flag_outlined),
                label: Text(escalated ? 'De-escalate' : 'Escalate'),
              ),
              TextButton.icon(
                onPressed: workers.isEmpty
                    ? null
                    : () => _openFollowUpDialog(context, data, issue, workers, user),
                icon: Icon(Icons.fact_check_outlined),
                label: const Text('Assign follow-up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFollowUpDialog(
    BuildContext context,
    DataProvider data,
    VerificationIssue issue,
    List<User> workers,
    User user,
  ) {
    final noteController = TextEditingController(text: issue.description);
    DateTime? dueDate = DateTime.now().add(const Duration(days: 2));
    TaskPriority selectedPriority = issue.severity == IssueSeverity.high
        ? TaskPriority.high
        : (issue.severity == IssueSeverity.low ? TaskPriority.low : TaskPriority.medium);
    String? selectedWorkerId = issue.ashaId ?? (workers.isNotEmpty ? workers.first.id : null);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Assign follow-up task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (workers.isEmpty)
                      const Text('No ASHA workers available')
                    else
                      DropdownButtonFormField<String>(
                        value: selectedWorkerId,
                        decoration: const InputDecoration(labelText: 'Assign to'),
                        items: workers
                            .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedWorkerId = value),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      value: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPriority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final today = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: dueDate ?? today,
                            firstDate: today,
                            lastDate: today.add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => dueDate = picked);
                          }
                        },
                        icon: const Icon(Icons.event_outlined),
                        label: Text(dueDate == null ? 'Pick due date' : _formatDate(dueDate!)),
                      ),
                    ),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Instructions for ASHA'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedWorkerId == null
                      ? null
                      : () {
                          final target = _workerFromList(workers, selectedWorkerId);
                          data.assignFollowUpFromIssue(
                            issue,
                            createdByUserId: user.id,
                            createdByName: user.name,
                            overrideAshaId: target?.id,
                            overrideAshaName: target?.name,
                            notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                            dueDate: dueDate,
                            priority: selectedPriority,
                          );
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Follow-up task assigned')),
                          );
                        },
                  child: const Text('Assign task'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => noteController.dispose());
  }

  User? _workerFromList(List<User> workers, String? id) {
    if (id == null) return null;
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}

class _PHCDashboard extends StatelessWidget {
    final User user;
    const _PHCDashboard({required this.user});

    @override
    Widget build(BuildContext context) {
      // Placeholder for higher-level reporting and analytics
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.name.split(' ').first}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'PHC Reporting',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: const [SyncStatus(), SizedBox(width: 8)],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('Analytics and reports will appear here.',
                        style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 400),
                ]),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showIssueDetails(BuildContext context, VerificationIssue issue, DataProvider data) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final resolved = data.isIssueResolved(issue.id);
        final escalated = data.isIssueEscalated(issue.id);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSeverityChip(sheetCtx, issue.severity),
                    if (issue.patientName != null)
                      _buildInfoChip(sheetCtx, Icons.person_outline, issue.patientName!),
                    if (issue.ashaName != null)
                      _buildInfoChip(sheetCtx, Icons.badge_outlined, 'ASHA: ${issue.ashaName}'),
                    _buildInfoChip(sheetCtx, Icons.schedule, _formatTimeAgo(issue.detectedAt)),
                    _buildInfoChip(sheetCtx, Icons.article_outlined, _recordTypeLabel(issue)),
                    if (resolved)
                      _buildInfoChip(sheetCtx, Icons.check_circle, 'Resolved', iconColor: Colors.green.shade600),
                    if (escalated)
                      _buildInfoChip(sheetCtx, Icons.flag, 'Escalated', iconColor: Colors.deepOrange.shade600),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  issue.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (issue.metadata != null && issue.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Metadata',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...issue.metadata!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value?.toString() ?? '-',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeverityChip(BuildContext context, IssueSeverity severity) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {Color? iconColor}) {
  final theme = Theme.of(context);
  final background = theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6);
    final textColor = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Color _severityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.high:
        return Colors.red.shade600;
      case IssueSeverity.medium:
        return Colors.orange.shade600;
      case IssueSeverity.low:
        return Colors.blue.shade600;
    }
  }

  String _recordTypeLabel(VerificationIssue issue) {
    switch (issue.recordType) {
      case VerificationRecordType.patient:
        return 'Patient record';
      case VerificationRecordType.ancVisit:
        return 'ANC visit';
      case VerificationRecordType.immunization:
        return 'Immunization';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.isNegative) {
      final ahead = timestamp.difference(now);
      if (ahead.inMinutes < 60) return 'in ${ahead.inMinutes}m';
      if (ahead.inHours < 24) return 'in ${ahead.inHours}h';
      return 'in ${ahead.inDays}d';
    }

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final months = diff.inDays ~/ 30;
    return months <= 1 ? '1mo ago' : '${months}mo ago';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    return '$year-$month-$day';
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
