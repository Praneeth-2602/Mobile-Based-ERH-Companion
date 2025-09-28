import 'package:flutter/material.dart';
import '../services/cloud_sync_service.dart';

class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showText;
  final double iconSize;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.errorMessage,
    this.onRetry,
    this.showText = true,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(theme),
        if (showText) ...[
          const SizedBox(width: 8),
          _buildText(theme),
        ],
        if (status == SyncStatus.failed && onRetry != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Icon(
              Icons.refresh,
              size: iconSize,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon(ThemeData theme) {
    switch (status) {
      case SyncStatus.pending:
        return Icon(
          Icons.cloud_upload_outlined,
          size: iconSize,
          color: Colors.orange.shade600,
        );
      case SyncStatus.syncing:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        );
      case SyncStatus.synced:
        return Icon(
          Icons.cloud_done_outlined,
          size: iconSize,
          color: Colors.green.shade600,
        );
      case SyncStatus.failed:
        return Icon(
          Icons.cloud_off_outlined,
          size: iconSize,
          color: Colors.red.shade600,
        );
      case SyncStatus.conflict:
        return Icon(
          Icons.warning_outlined,
          size: iconSize,
          color: Colors.amber.shade600,
        );
    }
  }

  Widget _buildText(ThemeData theme) {
    String text;
    Color color;

    switch (status) {
      case SyncStatus.pending:
        text = 'Pending sync';
        color = Colors.orange.shade600;
        break;
      case SyncStatus.syncing:
        text = 'Syncing...';
        color = theme.colorScheme.primary;
        break;
      case SyncStatus.synced:
        text = 'Synced';
        color = Colors.green.shade600;
        break;
      case SyncStatus.failed:
        text = 'Sync failed';
        color = Colors.red.shade600;
        break;
      case SyncStatus.conflict:
        text = 'Conflict';
        color = Colors.amber.shade600;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class SyncStatusCard extends StatelessWidget {
  final String title;
  final SyncStatus status;
  final String? lastSyncTime;
  final String? errorMessage;
  final VoidCallback? onSync;
  final VoidCallback? onViewDetails;

  const SyncStatusCard({
    super.key,
    required this.title,
    required this.status,
    this.lastSyncTime,
    this.errorMessage,
    this.onSync,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SyncStatusIndicator(
                  status: status,
                  showText: false,
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SyncStatusIndicator(
              status: status,
              errorMessage: errorMessage,
              onRetry: onSync,
            ),
            if (lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last synced: $lastSyncTime',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onSync != null || onViewDetails != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onViewDetails != null)
                    TextButton(
                      onPressed: onViewDetails,
                      child: const Text('View Details'),
                    ),
                  if (onSync != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onSync,
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Sync'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SyncSummaryWidget extends StatelessWidget {
  final SyncSummary summary;
  final VoidCallback? onRetryFailed;

  const SyncSummaryWidget({
    super.key,
    required this.summary,
    this.onRetryFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sync Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatSyncTime(summary.syncTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: summary.successRate,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.isComplete ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.syncedRecords}/${summary.totalRecords} records synced (${(summary.successRate * 100).toInt()}%)',
              style: theme.textTheme.bodySmall,
            ),
            
            if (summary.hasFailures || summary.hasConflicts) ...[
              const SizedBox(height: 16),
              if (summary.hasFailures)
                _buildStatusRow(
                  context,
                  Icons.error_outline,
                  Colors.red,
                  '${summary.failedRecords} failed',
                ),
              if (summary.hasConflicts)
                _buildStatusRow(
                  context,
                  Icons.warning_amber_outlined,
                  Colors.amber,
                  '${summary.conflictedRecords} conflicts',
                ),
            ],
            
            if (summary.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  'View Errors (${summary.errors.length})',
                  style: const TextStyle(fontSize: 14),
                ),
                children: summary.errors.map((error) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(error, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ],
            
            if (onRetryFailed != null && summary.hasFailures) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetryFailed,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry Failed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final difference = now.difference(syncTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}