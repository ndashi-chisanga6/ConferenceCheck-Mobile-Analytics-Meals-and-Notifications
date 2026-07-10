import 'package:conference_check_mobile/core/widgets/metric_card.dart';
import 'package:conference_check_mobile/core/widgets/result_banner.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('metric card shows value and label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const MetricCard(
          label: 'Checked in',
          value: '128',
          icon: Icons.how_to_reg,
        ),
      ),
    );

    expect(find.text('128'), findsOneWidget);
    expect(find.text('Checked in'), findsOneWidget);
    expect(find.byIcon(Icons.how_to_reg), findsOneWidget);
  });

  testWidgets('result banner picks the icon for each kind', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            ResultBanner(message: 'Redeemed', kind: ResultKind.success),
            ResultBanner(message: 'Queued offline', kind: ResultKind.warning),
            ResultBanner(message: 'Already redeemed', kind: ResultKind.error),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Queued offline'), findsOneWidget);
  });

  testWidgets('status badge renders its label', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatusBadge('over_capacity', color: Colors.red)),
    );

    expect(find.text('over_capacity'), findsOneWidget);
  });
}
