import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealRedemptionsScreen extends ConsumerWidget {
  const MealRedemptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redemptions = ref.watch(mealRedemptionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Meal redemption history')),
      body: redemptions.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(mealRedemptionsProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'No meal redemptions yet.')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: Text('Redemption #${item.id}'),
                      subtitle: Text(formatDateTime(item.redeemedAt)),
                      trailing: Text(item.deviceId ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
