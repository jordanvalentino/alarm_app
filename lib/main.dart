import 'package:alarm/app/app.dart';
import 'package:alarm/app/globals.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

main() async {
  // make sure all flutter widget binding are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // force orientation to portrait up only (does not support landscape mode)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // initialize android alarm manager
  await AndroidAlarmManager.initialize();

  runApp(AlarmApp());
}
