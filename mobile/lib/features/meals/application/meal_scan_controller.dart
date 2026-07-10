import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanState {
  const ScanState({this.loading = false, this.message, this.success});
  final bool loading;
  final String? message;
  final bool? success;
}

class MealScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<void> scan(String token) async {
    final event = ref.read(selectedEventProvider);
    if (event == null || token.trim().isEmpty) return;
    state = const ScanState(loading: true);
    try {
      await ref
          .read(mealsApiProvider)
          .scan(event.id, token.trim(), deviceId: 'flutter-mobile');
      ref.invalidate(mealRedemptionsProvider);
      ref.invalidate(mealVouchersProvider);
      state = const ScanState(
        message: 'Voucher redeemed successfully.',
        success: true,
      );
    } on ApiException catch (error) {
      state = ScanState(message: error.message, success: false);
    } catch (error) {
      state = ScanState(message: error.toString(), success: false);
    }
  }
}

final mealScanControllerProvider =
    NotifierProvider<MealScanController, ScanState>(MealScanController.new);
