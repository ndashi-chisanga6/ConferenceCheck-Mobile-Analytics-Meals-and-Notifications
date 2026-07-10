import 'package:conference_check_mobile/app/router.dart';
import 'package:conference_check_mobile/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConferenceCheckApp extends ConsumerWidget {
  const ConferenceCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ConferenceCheck Mobile',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
