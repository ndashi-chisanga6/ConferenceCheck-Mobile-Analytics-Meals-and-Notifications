import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/features/attendee/application/attendee_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends ConsumerWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAttendee = ref.watch(myAttendeeProvider);

    return myAttendee.when(
      loading: () => const LoadingView(message: 'Loading your QR...'),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(myAttendeeProvider),
      ),
      data: (attendee) => RefreshIndicator(
        onRefresh: () => ref.refresh(myAttendeeProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'My attendee QR',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(attendee.fullName),
                    const SizedBox(height: 18),
                    QrImageView(data: attendee.qrToken, size: 220),
                    const SizedBox(height: 12),
                    Text(attendee.qrToken),
                    const SizedBox(height: 8),
                    Text('Ticket: ${attendee.ticketCode}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Show this code at event check-in and session doors.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
