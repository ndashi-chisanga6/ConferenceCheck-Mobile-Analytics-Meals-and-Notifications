import 'package:conference_check_mobile/core/widgets/app_button.dart';
import 'package:conference_check_mobile/core/widgets/app_text_field.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/features/sessions/application/session_scan_controller.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:conference_check_mobile/features/sync/presentation/pending_scans_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SessionScannerScreen extends ConsumerStatefulWidget {
  const SessionScannerScreen({super.key});

  @override
  ConsumerState<SessionScannerScreen> createState() =>
      _SessionScannerScreenState();
}

class _SessionScannerScreenState extends ConsumerState<SessionScannerScreen> {
  final _manual = TextEditingController();
  bool _locked = false;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final selected = ref.watch(selectedSessionProvider);
    final scan = ref.watch(sessionScanControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Session attendance scan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PendingScansBar(),
          sessions.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(error.toString()),
            data: (items) => DropdownButtonFormField<int>(
              initialValue: selected?.id,
              decoration: const InputDecoration(labelText: 'Session'),
              items: [
                for (final item in items)
                  DropdownMenuItem(value: item.id, child: Text(item.title)),
              ],
              onChanged: (id) {
                for (final item in items) {
                  if (item.id == id) {
                    ref.read(selectedSessionProvider.notifier).select(item);
                    return;
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 240,
              child: MobileScanner(
                onDetect: (capture) {
                  if (_locked) return;
                  final value = capture.barcodes.isEmpty
                      ? null
                      : capture.barcodes.first.rawValue;
                  if (value == null || value.isEmpty) return;
                  _locked = true;
                  ref
                      .read(sessionScanControllerProvider.notifier)
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
            label: 'Manual attendee QR token',
            icon: Icons.keyboard,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Submit attendance',
            icon: Icons.send,
            loading: scan.loading,
            onPressed: () => ref
                .read(sessionScanControllerProvider.notifier)
                .scan(_manual.text),
          ),
          if (scan.message != null) ...[
            const SizedBox(height: 12),
            ResultBanner(
              message: scan.message!,
              kind: scan.success == true
                  ? ResultKind.success
                  : (scan.queued ? ResultKind.warning : ResultKind.error),
            ),
          ],
        ],
      ),
    );
  }
}
