import 'dart:async';

import 'package:alarm/app/models/alarm_history.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmNotification {
  // notification plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // reference to alarm history instance
  final AlarmHistory _alarmHistory;
  // notification payload stream
  final StreamController<String> _payloadController =
      StreamController<String>();

  Stream<String> get stream => _payloadController.stream;

  /// Creates a new [AlarmNotification] instance.
  ///
  /// Need an [AlarmHistory] instance as a mandatory parameter.
  AlarmNotification(this._alarmHistory) {
    _init();
  }

  /// Initialize alarm notification.
  void _init() async {
    // android specific initialization settings
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // notification initialization settings for platform specifics settings
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    // initialize notification plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  /// Function called when notification is selected.
  void _onSelectNotification(String? selectedPayload) async {
    // if payload from notification is not null then add payload to payload stream.
    if (selectedPayload != null) {
      addPayload(selectedPayload);

      switch (selectedPayload) {
        // if it is a payload from alarm, add new alarm history.
        case "payload_alarm":
          // calculate time difference between the last alarm set and current payload.
          _alarmHistory
              .addHistory(DateTime.now().difference(_alarmHistory.lastAlarm!));
          break;
        default:
      }
    }
  }

  /// Shows local push notification on the device.
  void showNotification(int notifId, String notifTitle, String notifBody,
      String notifPayload) async {
    // set android specific notification channel detail
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      DateTime.now().microsecondsSinceEpoch.toString(),
      'alarm-app',
      channelDescription: 'alarm-notification',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('alarm_tone'),
      playSound: true,
    );

    // set channel details
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // show notification
    await _flutterLocalNotificationsPlugin.show(
      notifId,
      notifTitle,
      notifBody,
      platformChannelSpecifics,
      payload: notifPayload,
    );
  }

  /// Add notification payload to payload stream.
  ///
  /// Listener can react to specific payload emitted by the stream.
  void addPayload(dynamic addedPayload) =>
      _payloadController.sink.add(addedPayload);
}
