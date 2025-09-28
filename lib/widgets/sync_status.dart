import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class SyncStatus extends StatelessWidget {
  const SyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final stats = dataProvider.dashboardStats;
        final hasConnectivity = dataProvider.hasConnectivity;
        final isLoading = dataProvider.isLoading;
        
        Color statusColor;
        String statusText;
        IconData statusIcon;
        
        if (isLoading) {
          statusColor = Colors.orange;
          statusText = 'Syncing...';
          statusIcon = Icons.sync;
        } else if (!hasConnectivity) {
          statusColor = Colors.red;
          statusText = 'Offline';
          statusIcon = Icons.wifi_off;
        } else if (stats.syncProgress == 1.0) {
          statusColor = Colors.green;
          statusText = 'Synced';
          statusIcon = Icons.check_circle;
        } else {
          statusColor = Colors.orange;
          statusText = 'Sync needed';
          statusIcon = Icons.sync_problem;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                )
              else
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
              
              const SizedBox(width: 6),
              
              Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}