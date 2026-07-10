import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/events/application/selected_event_controller.dart';
import 'package:conference_check_mobile/features/events/data/event_models.dart';
import 'package:conference_check_mobile/features/events/data/events_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsApiProvider = Provider<EventsApi>(
  (ref) => EventsApi(ref.watch(apiClientProvider)),
);

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final events = await ref.watch(eventsApiProvider).fetchEvents();
  await ref.read(selectedEventProvider.notifier).restore(events);
  return events;
});

final selectedEventProvider = NotifierProvider<SelectedEventController, Event?>(
  SelectedEventController.new,
);
