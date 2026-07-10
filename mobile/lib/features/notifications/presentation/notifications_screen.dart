import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/notifications/application/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, this.canSend = false});

  final bool canSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      body: notifications.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No notifications yet.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(notificationsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.notifications_none),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.message}\n${formatDateTime(item.sentAt)}',
                        ),
                        isThreeLine: true,
                        trailing: StatusBadge(item.status),
                        onTap: () => context.push(
                          '/notifications/${item.id}',
                          extra: item,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: canSend
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/send-notification'),
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            )
          : null,
    );
  }
}
