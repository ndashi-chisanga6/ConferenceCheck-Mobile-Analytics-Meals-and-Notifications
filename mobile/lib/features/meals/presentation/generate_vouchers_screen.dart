import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenerateVouchersScreen extends ConsumerStatefulWidget {
  const GenerateVouchersScreen({super.key});

  @override
  ConsumerState<GenerateVouchersScreen> createState() =>
      _GenerateVouchersScreenState();
}

class _GenerateVouchersScreenState
    extends ConsumerState<GenerateVouchersScreen> {
  String? _message;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(mealCategoriesProvider);
    final event = ref.watch(selectedEventProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Generate vouchers')),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) => items.isEmpty
            ? const EmptyView(message: 'Create a meal category first.')
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Generate vouchers for all attendees in the selected event. Existing attendee/category vouchers are skipped by the backend.',
                  ),
                  const SizedBox(height: 12),
                  for (final item in items)
                    Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.status),
                        trailing: FilledButton(
                          onPressed: _loading || event == null
                              ? null
                              : () async {
                                  setState(() => _loading = true);
                                  final message = await ref
                                      .read(mealsApiProvider)
                                      .generate(event.id, item.id);
                                  ref.invalidate(mealVouchersProvider);
                                  setState(() {
                                    _message = message;
                                    _loading = false;
                                  });
                                },
                          child: const Text('Generate'),
                        ),
                      ),
                    ),
                  if (_message != null)
                    ResultBanner(message: _message!, kind: ResultKind.success),
                ],
              ),
      ),
    );
  }
}
