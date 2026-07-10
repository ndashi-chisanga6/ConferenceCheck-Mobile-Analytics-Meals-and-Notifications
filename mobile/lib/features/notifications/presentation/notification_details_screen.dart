import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/features/notifications/data/notification_models.dart';
import 'package:flutter/material.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({required this.notification, super.key});

  final EventNotification notification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(notification.message),
                  const Divider(height: 28),
                  Text('Target: ${notification.targetType}'),
                  Text('Status: ${notification.status}'),
                  Text('Sent: ${formatDateTime(notification.sentAt)}'),
                  if (notification.recipientsCount != null)
                    Text('Recipients: ${notification.recipientsCount}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
