import 'package:conference_check_mobile/core/storage/selected_event_storage.dart';
import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/events/data/event_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedEventController extends Notifier<Event?> {
  late final SelectedEventStorage _storage = ref.read(
    selectedEventStorageProvider,
  );

  @override
  Event? build() => null;

  Future<void> restore(List<Event> events) async {
    final id = await _storage.read();
    if (id == null || events.isEmpty) return;
    for (final event in events) {
      if (event.id == id) {
        state = event;
        return;
      }
    }
  }

  Future<void> select(Event event) async {
    await _storage.save(event.id);
    state = event;
  }

  Future<void> clear() async {
    await _storage.clear();
    state = null;
  }
}
