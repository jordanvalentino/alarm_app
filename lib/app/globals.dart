import 'dart:math';

import 'package:intl/intl.dart';

import 'models/alarm_history.dart';
import 'models/alarm_notification.dart';

AlarmHistory alarmHistory = AlarmHistory();
AlarmNotification alarmNotification = AlarmNotification(alarmHistory);

List<int> alarmIds = <int>[];

void fireAlarm() async {
  alarmNotification.showNotification(
    Random().nextInt(86400),
    "Alarm",
    "It's already ${DateFormat('HH:mm').format(DateTime.now())}",
    "payload_alarm",
  );

  // print("Alarm fired at ${DateTime.now()}");
}
