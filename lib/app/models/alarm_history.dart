import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AlarmHistory {
  // SharedPreferences instance
  late SharedPreferences _preference;

  // list of alarm histories
  List<int> _histories = <int>[];
  // last alarm set
  late DateTime? _lastAlarm;

  List<int> get histories => List.unmodifiable(_histories);
  DateTime? get lastAlarm => _lastAlarm;

  /// Creates a new [AlarmHistory] instance.
  AlarmHistory() {
    _init();
  }

  /// Initialize alarm history.
  void _init() async {
    _preference = await SharedPreferences.getInstance();
    _syncAll();
  }

  /// Synchronize all data related to [AlarmHistory].
  ///
  /// Related data :
  /// - alarm_histories : List of duration history (in seconds) since alarm rang until stopped.
  /// - last_alarm : Last alarm set by user.
  void _syncAll() {
    _syncHistories();
    _syncLastAlarm();
  }

  /// Get alarm histories from local storage.
  void _syncHistories() {
    // try to get alarm_history from local storage, if not found then set an empty list.
    _histories = _preference.containsKey("alarm_history")
        ? List<int>.from(jsonDecode(_preference.getString("alarm_history")!))
        : [];
  }

  /// Get last alarm set from local storage.
  void _syncLastAlarm() {
    // try to get last_alarm from local storage, if not found then set null.
    _lastAlarm = _preference.containsKey("last_alarm")
        ? DateTime.fromMillisecondsSinceEpoch(_preference.getInt("last_alarm")!)
        : null;
  }

  /// Add new alarm history.
  /// Takes [Duration] object as a parameter.
  void addHistory(Duration duration) {
    _histories.add(duration.inSeconds);
    _preference.setString('alarm_history', jsonEncode(_histories));
  }

  /// Clear all recorded alarm histories from local storage.
  void clearHistory() {
    _preference.clear();
    _syncHistories();
  }

  /// Set new alarm.
  /// Newly set alarm will be recorded as the last set alarm.
  /// Takes [DateTime] object as a parameter.
  void setAlarm(DateTime dateTime) {
    _lastAlarm = dateTime;
    _preference.setInt('last_alarm', _lastAlarm!.millisecondsSinceEpoch);
  }

  /// Remove last set alarm.
  void clearAlarm() {
    _lastAlarm = null;
    _preference.remove('last_alarm');
  }
}
