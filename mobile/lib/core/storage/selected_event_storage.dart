import 'package:shared_preferences/shared_preferences.dart';

class SelectedEventStorage {
  static const _key = 'selected_event_id';

  Future<int?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> save(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, eventId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
