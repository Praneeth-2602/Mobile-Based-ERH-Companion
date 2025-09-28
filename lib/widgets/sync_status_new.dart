import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class SyncStatus extends StatefulWidget {
  const SyncStatus({super.key});

  @override
  State<SyncStatus> createState() => _SyncStatusState();
}

class _SyncStatusState extends State<SyncStatus> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final stats = dataProvider.dashboardStats;
        final isOnline = stats.hasConnectivity;
        final syncProgress = stats.syncProgress;
        final isSyncing = syncProgress > 0 && syncProgress < 1;
        
        if (isSyncing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }

        IconData statusIcon;
        String statusText;
        
        if (isSyncing) {
          statusIcon = Icons.sync_rounded;
          statusText = 'Syncing...';
        } else if (isOnline && syncProgress == 1.0) {
          statusIcon = Icons.cloud_done_rounded;
          statusText = 'Synced';
        } else if (isOnline) {
          statusIcon = Icons.cloud_sync_rounded;
          statusText = 'Pending';
        } else {
          statusIcon = Icons.cloud_off_rounded;
          statusText = 'Offline';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: isSyncing ? _rotationController.value * 2 * 3.14159 : 0,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: (!isOnline || isSyncing) ? _pulseAnimation.value : 1.0,
                          child: Icon(
                            statusIcon,
                            color: Colors.white,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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