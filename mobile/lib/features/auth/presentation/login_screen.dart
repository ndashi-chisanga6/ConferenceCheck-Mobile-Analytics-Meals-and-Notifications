import 'package:conference_check_mobile/core/widgets/app_button.dart';
import 'package:conference_check_mobile/core/widgets/app_text_field.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/notifications/application/firebase_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'organiser@example.com');
  final _password = TextEditingController(text: 'password');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        ref.read(firebaseMessagingServiceProvider).registerDeviceToken();
        context.go('/events');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'ConferenceCheck Mobile',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analytics, meals, sessions and notifications for your conference team.',
            ),
            const SizedBox(height: 28),
            AppTextField(
              controller: _email,
              label: 'Email',
              icon: Icons.mail_outline,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _password,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Login',
              icon: Icons.login,
              loading: auth.loading,
              onPressed: () => ref
                  .read(authControllerProvider.notifier)
                  .login(_email.text, _password.text),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DemoChip(
                  label: 'Organiser Demo',
                  email: 'organiser@example.com',
                  onPick: _fill,
                ),
                _DemoChip(
                  label: 'Scanner Demo',
                  email: 'scanner@example.com',
                  onPick: _fill,
                ),
                _DemoChip(
                  label: 'Attendee Demo',
                  email: 'attendee@example.com',
                  onPick: _fill,
                ),
              ],
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 16),
              ResultBanner(message: auth.error!, kind: ResultKind.error),
            ],
          ],
        ),
      ),
    );
  }

  void _fill(String email) {
    _email.text = email;
    _password.text = 'password';
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({
    required this.label,
    required this.email,
    required this.onPick,
  });

  final String label;
  final String email;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.person_outline, size: 18),
      label: Text(label),
      onPressed: () => onPick(email),
    );
  }
}
