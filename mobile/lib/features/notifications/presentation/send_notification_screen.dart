import 'package:conference_check_mobile/core/widgets/app_button.dart';
import 'package:conference_check_mobile/core/widgets/app_text_field.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/features/notifications/application/send_notification_controller.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  String _targetType = 'all_attendees';
  int? _sessionId;

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendNotificationControllerProvider);
    final sessions = ref.watch(sessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Send notification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(controller: _title, label: 'Title', icon: Icons.title),
          const SizedBox(height: 12),
          AppTextField(
            controller: _message,
            label: 'Message',
            icon: Icons.message_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _targetType,
            decoration: const InputDecoration(labelText: 'Target'),
            items: const [
              DropdownMenuItem(
                value: 'all_attendees',
                child: Text('All attendees'),
              ),
              DropdownMenuItem(
                value: 'session_attendees',
                child: Text('Session attendees'),
              ),
              DropdownMenuItem(value: 'organisers', child: Text('Organisers')),
              DropdownMenuItem(value: 'scanners', child: Text('Scanners')),
              DropdownMenuItem(value: 'custom', child: Text('Custom')),
            ],
            onChanged: (value) =>
                setState(() => _targetType = value ?? 'all_attendees'),
          ),
          if (_targetType == 'session_attendees') ...[
            const SizedBox(height: 12),
            sessions.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(error.toString()),
              data: (items) => DropdownButtonFormField<int>(
                initialValue: _sessionId,
                decoration: const InputDecoration(labelText: 'Target session'),
                items: [
                  for (final session in items)
                    DropdownMenuItem(
                      value: session.id,
                      child: Text(session.title),
                    ),
                ],
                onChanged: (value) => setState(() => _sessionId = value),
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Send notification',
            icon: Icons.send,
            loading: state.loading,
            onPressed: () => ref
                .read(sendNotificationControllerProvider.notifier)
                .send(
                  title: _title.text,
                  message: _message.text,
                  targetType: _targetType,
                  targetSessionId: _sessionId,
                ),
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
