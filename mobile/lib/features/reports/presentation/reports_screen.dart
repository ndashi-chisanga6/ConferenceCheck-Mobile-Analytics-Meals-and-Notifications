import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/reports/application/reports_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(selectedEventProvider);
    final api = ref.watch(reportsApiProvider);
    final reports = event == null ? [] : api.reports(event.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final report in reports)
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(report.title),
              subtitle: Text(report.description),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'copy') {
                    await Clipboard.setData(
                      ClipboardData(text: api.absoluteUrl(report.path)),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report URL copied.')),
                      );
                    }
                  } else {
                    await api.download(report);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'open', child: Text('Download/open')),
                  PopupMenuItem(value: 'copy', child: Text('Copy URL')),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
