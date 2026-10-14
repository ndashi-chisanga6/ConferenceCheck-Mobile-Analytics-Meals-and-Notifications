import 'package:conference_check_mobile/app/theme.dart';
import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/attendee/application/attendee_providers.dart';
import 'package:conference_check_mobile/features/meals/data/meal_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The attendee's meal vouchers, one card per meal category. An unused
/// voucher shows its qr_token as a QR code for the meal scanner; a redeemed
/// one shows when it was redeemed instead, so it cannot be presented again.
class MyMealsScreen extends ConsumerWidget {
  const MyMealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAttendee = ref.watch(myAttendeeProvider);

    return myAttendee.when(
      loading: () => const LoadingView(message: 'Loading your meals...'),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(myAttendeeProvider),
      ),
      data: (attendee) {
        if (attendee.mealVouchers.isEmpty) {
          return const EmptyView(
            message: 'You have no meal vouchers for this event.',
            icon: Icons.restaurant_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(myAttendeeProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                'Show a meal QR at the serving point. Each voucher works once.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              for (final voucher in attendee.mealVouchers)
                _VoucherCard(voucher: voucher),
            ],
          ),
        );
      },
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({required this.voucher});

  final MealVoucher voucher;

  @override
  Widget build(BuildContext context) {
    final category = voucher.category;
    final redeemed = voucher.isRedeemed;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppBrand.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category?.name ?? 'Meal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusBadge(
                  redeemed ? 'Redeemed' : 'Unused',
                  color: redeemed ? AppBrand.danger : AppBrand.ok,
                ),
              ],
            ),
            if (category?.startsAt != null || category?.endsAt != null) ...[
              const SizedBox(height: 4),
              Text(
                formatTimeRange(category?.startsAt, category?.endsAt),
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
            const SizedBox(height: 14),
            if (redeemed)
              Text(
                'Redeemed ${formatDateTime(voucher.redeemedAt)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: QrImageView(
                    data: voucher.qrToken,
                    size: 200,
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
              ),
            const SizedBox(height: 10),
            Center(
              child: SelectableText(
                voucher.qrToken,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
