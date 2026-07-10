import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(mealCategoriesProvider);
    final redemptions = ref.watch(mealRedemptionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(mealCategoriesProvider);
        ref.invalidate(mealRedemptionsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => context.push('/meal-scan'),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan voucher'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/meal-redemptions'),
                icon: const Icon(Icons.history),
                label: const Text('History'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/generate-vouchers'),
                icon: const Icon(Icons.add_card),
                label: const Text('Generate'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Meal categories',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          categories.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(mealCategoriesProvider),
            ),
            data: (items) => items.isEmpty
                ? const EmptyView(message: 'No meal categories yet.')
                : Column(
                    children: [
                      for (final item in items)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu),
                            title: Text(item.name),
                            subtitle: Text(
                              formatTimeRange(item.startsAt, item.endsAt),
                            ),
                            trailing: StatusBadge(item.status),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recent redemptions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          redemptions.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(mealRedemptionsProvider),
            ),
            data: (items) => items.isEmpty
                ? const EmptyView(message: 'No meal redemptions yet.')
                : Column(
                    children: [
                      for (final item in items.take(5))
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text('Redemption #${item.id}'),
                            subtitle: Text(formatDateTime(item.redeemedAt)),
                            trailing: Text(item.deviceId ?? ''),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
