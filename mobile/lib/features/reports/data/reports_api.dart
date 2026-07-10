import 'dart:io';

import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/config/env.dart';
import 'package:conference_check_mobile/features/reports/data/report_models.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ReportsApi {
  const ReportsApi(this._client);

  final ApiClient _client;

  List<ReportDefinition> reports(int eventId) => [
    ReportDefinition(
      title: 'Attendance Report',
      description: 'All attendee check-in records.',
      path: '/events/$eventId/reports/attendance.csv',
    ),
    ReportDefinition(
      title: 'Meal Redemption Report',
      description: 'Redeemed meal vouchers by attendee.',
      path: '/events/$eventId/reports/meals.csv',
    ),
    ReportDefinition(
      title: 'Session Attendance Report',
      description: 'Session capacity and attendance totals.',
      path: '/events/$eventId/reports/sessions.csv',
    ),
    ReportDefinition(
      title: 'Notification Report',
      description: 'Notification status and recipient totals.',
      path: '/events/$eventId/reports/notifications.csv',
    ),
  ];

  String absoluteUrl(String path) => '${Env.apiBaseUrl}$path';

  Future<File> download(ReportDefinition report) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = report.path.split('/').last;
    final file = File('${directory.path}/$fileName');
    final response = await _client.dio.get<List<int>>(
      report.path,
      options: Options(responseType: ResponseType.bytes),
    );
    await file.writeAsBytes(response.data ?? []);
    await OpenFilex.open(file.path);
    return file;
  }
}
