import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/reports/data/reports_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsApiProvider = Provider<ReportsApi>(
  (ref) => ReportsApi(ref.watch(apiClientProvider)),
);
