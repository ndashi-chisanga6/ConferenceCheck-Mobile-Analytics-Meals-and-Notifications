import 'package:conference_check_mobile/core/widgets/app_button.dart';
import 'package:conference_check_mobile/core/widgets/app_text_field.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/features/meals/application/meal_scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MealScannerScreen extends ConsumerStatefulWidget {
  const MealScannerScreen({super.key});

  @override
  ConsumerState<MealScannerScreen> createState() => _MealScannerScreenState();
}

class _MealScannerScreenState extends ConsumerState<MealScannerScreen> {
  final _manual = TextEditingController();
  bool _locked = false;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealScanControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Meal voucher scan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 260,
              child: MobileScanner(
                onDetect: (capture) {
                  if (_locked) return;
                  final value = capture.barcodes.isEmpty
                      ? null
                      : capture.barcodes.first.rawValue;
                  if (value == null || value.isEmpty) return;
                  _locked = true;
                  ref
                      .read(mealScanControllerProvider.notifier)
                      .scan(value)
                      .whenComplete(() {
                        Future<void>.delayed(
                          const Duration(seconds: 2),
                          () => _locked = false,
                        );
                      });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _manual,
            label: 'Manual voucher token',
            icon: Icons.keyboard,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Submit token',
            icon: Icons.send,
            loading: state.loading,
            onPressed: () => ref
                .read(mealScanControllerProvider.notifier)
                .scan(_manual.text),
          ),
          if (state.message != null) ...[
            const SizedBox(height: 12),
            ResultBanner(
              message: state.message!,
              kind: state.success == true
                  ? ResultKind.success
                  : ResultKind.error,
            ),
          ],
        ],
      ),
    );
  }
}
