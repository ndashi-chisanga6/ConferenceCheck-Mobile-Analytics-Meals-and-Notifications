import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_api.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendeeApiProvider = Provider<AttendeeApi>(
  (ref) => AttendeeApi(ref.watch(apiClientProvider)),
);

final myAttendeeProvider = FutureProvider<Attendee>((ref) {
  final event = ref.watch(selectedEventProvider);
  if (event == null) {
    throw const ApiException('Select an event to load your attendee QR.');
  }
  return ref.watch(attendeeApiProvider).fetchMyAttendee(event.id);
});
