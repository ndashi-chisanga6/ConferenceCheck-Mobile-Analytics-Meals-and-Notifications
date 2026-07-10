import 'package:conference_check_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders demo quick fill buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.text('Organiser Demo'), findsOneWidget);
    expect(find.text('Scanner Demo'), findsOneWidget);
    expect(find.text('Attendee Demo'), findsOneWidget);
  });
}
