/// A small typed key-value store, used for settings, consent, Pro ownership and
/// the success counts behind ads and prompts (DATA-8).
///
/// Keys are namespaced strings (`settings.theme_mode`, `counts.scans`). Every
/// write lands before the caller changes any in-memory state, so a failed write
/// leaves the app and the database agreeing.
abstract class KeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<int?> getInt(String key);

  Future<void> setInt(String key, int value);

  Future<bool?> getBool(String key);

  Future<void> setBool(String key, {required bool value});

  /// Adds [by] to the value at [key] (0 when unset) and returns the new value.
  Future<int> increment(String key, {int by = 1});

  Future<void> remove(String key);

  /// Every key currently stored, for export and for tests.
  Future<Map<String, String>> all();
}
