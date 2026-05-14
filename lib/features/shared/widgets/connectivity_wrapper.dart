import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/notifications/providers/notification_provider.dart';
import 'package:mind_print/features/shared/providers/connectivity_provider.dart';

class ConnectivityWrapper extends ConsumerStatefulWidget {
  const ConnectivityWrapper({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ConnectivityWrapper> createState() =>
      _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<ConnectivityWrapper> {
  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);

    ref.listen(isOfflineProvider, (previous, next) {
      if (previous == true && next == false) {
        // Just came online
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection restored. Syncing data...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _triggerSyncCompleteNotification();
      }
    });

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.redAccent,
                    child: const Text(
                      'You are offline. Data will sync when connected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  void _triggerSyncCompleteNotification() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref
          .read(notificationServiceProvider)
          .createNotification(
            userId: user.uid,
            title: 'Sync Complete',
            body: 'Your data has been successfully synced with the cloud.',
            type: 'alert',
          );
    }
  }
}
