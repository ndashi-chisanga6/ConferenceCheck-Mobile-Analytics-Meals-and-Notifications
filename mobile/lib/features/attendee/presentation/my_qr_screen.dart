import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends ConsumerWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final fallbackToken = user == null
        ? null
        : 'ATTENDEE-DEMO-${user.id.toString().padLeft(3, '0')}';

    if (fallbackToken == null) {
      return const EmptyView(message: 'No attendee account is loaded.');
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'My attendee QR',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                QrImageView(data: fallbackToken, size: 220),
                const SizedBox(height: 12),
                Text(fallbackToken),
                const SizedBox(height: 8),
                const Text(
                  'The current backend exposes attendee QR tokens through event attendee lists, not directly from /auth/me. This demo uses the seeded attendee token convention for the attendee account.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
