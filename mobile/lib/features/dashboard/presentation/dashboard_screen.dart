import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/metric_card.dart';
import 'package:conference_check_mobile/features/dashboard/application/analytics_providers.dart';
import 'package:conference_check_mobile/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:conference_check_mobile/features/dashboard/presentation/widgets/checkins_chart.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/dashboard/presentation/widgets/meals_chart.dart';
import 'package:conference_check_mobile/features/dashboard/presentation/widgets/session_capacity_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsBundleProvider);

    return analytics.when(
      loading: () => const LoadingView(message: 'Loading analytics...'),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(analyticsBundleProvider),
      ),
      data: (bundle) {
        final summary = bundle.summary;
        final event = ref.watch(selectedEventProvider);
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(analyticsBundleProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DashboardHero(summary: summary, eventName: event?.name),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  MetricCard(
                    label: 'Meal vouchers',
                    value: '${summary.totalMealVouchers}',
                    icon: Icons.restaurant,
                  ),
                  MetricCard(
                    label: 'Redeemed meals',
                    value: '${summary.redeemedMealVouchers}',
                    icon: Icons.qr_code_2,
                  ),
                  MetricCard(
                    label: 'Meal rate',
                    value: '${summary.mealRedemptionPercentage}%',
                    icon: Icons.pie_chart_outline,
                  ),
                  MetricCard(
                    label: 'Session attendance',
                    value: '${summary.totalSessionAttendance}',
                    icon: Icons.event_seat,
                  ),
                  MetricCard(
                    label: 'Overcrowded',
                    value: '${summary.overcrowdedSessionsCount}',
                    icon: Icons.warning_amber,
                  ),
                  MetricCard(
                    label: 'Notifications',
                    value: '${summary.notificationsSent}',
                    icon: Icons.notifications_none,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Check-ins over time',
                child: CheckinsChart(points: bundle.checkIns),
              ),
              _Section(
                title: 'Meal redemptions',
                child: MealsChart(points: bundle.meals),
              ),
              _Section(
                title: 'Session capacity',
                child: SessionCapacityList(sessions: bundle.sessions),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
