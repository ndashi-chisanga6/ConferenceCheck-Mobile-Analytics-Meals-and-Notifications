import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/core/device/device_identity.dart';
import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:conference_check_mobile/features/sync/application/scan_sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanState {
  const ScanState({
    this.loading = false,
    this.message,
    this.success,
    this.queued = false,
  });
  final bool loading;
  final String? message;
  final bool? success;
  final bool queued;
}

class MealScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<void> scan(String token) async {
    final event = ref.read(selectedEventProvider);
    if (event == null || token.trim().isEmpty) return;
    state = const ScanState(loading: true);
    final deviceId = await ref.read(deviceIdentityProvider).id();
    try {
      await ref
          .read(mealsApiProvider)
          .scan(event.id, token.trim(), deviceId: deviceId);
      ref.invalidate(mealRedemptionsProvider);
      ref.invalidate(mealVouchersProvider);
      state = const ScanState(
        message: 'Voucher redeemed successfully.',
        success: true,
      );
      // Connectivity is clearly back: drain any offline backlog.
      await ref.read(scanSyncControllerProvider.notifier).flush();
    } on ApiException catch (error) {
      if (error.statusCode == null) {
        await ref
            .read(scanQueueProvider)
            .enqueue(
              QueuedScan(
                type: QueuedScan.meal,
                eventId: event.id,
                qrToken: token.trim(),
                deviceId: deviceId,
                queuedAt: DateTime.now(),
              ),
            );
        ref.invalidate(pendingScanCountProvider);
        state = const ScanState(
          message: 'No connection — scan saved and will sync when back online.',
          success: false,
          queued: true,
        );
      } else {
        state = ScanState(message: error.message, success: false);
      }
    } catch (error) {
      state = ScanState(message: error.toString(), success: false);
    }
  }
}

final mealScanControllerProvider =
    NotifierProvider<MealScanController, ScanState>(MealScanController.new);
