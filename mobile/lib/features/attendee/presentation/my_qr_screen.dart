import 'package:conference_check_mobile/app/theme.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/features/attendee/application/attendee_providers.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends ConsumerWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAttendee = ref.watch(myAttendeeProvider);
    final event = ref.watch(selectedEventProvider);

    return myAttendee.when(
      loading: () => const LoadingView(message: 'Loading your QR...'),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(myAttendeeProvider),
      ),
      data: (attendee) => RefreshIndicator(
        onRefresh: () => ref.refresh(myAttendeeProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            ClipPath(
              clipper: _TicketClipper(notchY: 0.42),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                    decoration: const BoxDecoration(
                      gradient: AppBrand.heroGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              color: AppBrand.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ATTENDEE PASS',
                              style: TextStyle(
                                color: AppBrand.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          attendee.fullName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        if (event != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Perforation
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: List.generate(
                        30,
                        (i) => Expanded(
                          child: Container(
                            height: 1.4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: i.isEven
                                ? Colors.black.withValues(alpha: 0.18)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // QR body
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppBrand.teal.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: QrImageView(
                            data: attendee.qrToken,
                            size: 208,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppBrand.ink,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppBrand.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppBrand.teal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            attendee.ticketCode,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppBrand.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Show this pass at event check-in and session doors.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded ticket outline with semicircular notches cut into both edges
/// at [notchY] (fraction of total height), like a torn boarding pass.
class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({required this.notchY});

  final double notchY;

  @override
  Path getClip(Size size) {
    const corner = 24.0;
    const notch = 12.0;
    final y = size.height * notchY;

    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(corner),
        ),
      );
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: notch));
    return Path.combine(PathOperation.difference, ticket, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => oldClipper.notchY != notchY;
}
