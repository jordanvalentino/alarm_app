import 'package:alarm/app/globals.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // distance for drag events to take effect
  final int _distanceToUpdateX = 15;
  final int _distanceToUpdateY = 40;

  // states of toggle buttons to set alarm on/off
  final List<bool> _toggleStates = [true, false];

  // permanent time : final datetime after drag event ends
  // temporary time : current datetime during updates / before drag event ends
  late DateTime _permTime;
  late DateTime _tempTime;

  // start point in X or Y axis when drag event starts
  late double _startX;
  late double _startY;

  _HomePageState() {
    DateTime now = DateTime.now();
    // initialize permanent and temporary time to current time with 0 as the second (does not support second precision)
    _permTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, 0);
    _tempTime = _permTime;
  }

  @override
  Widget build(BuildContext context) {
    // use stream builder to listen for payload stream changes
    return StreamBuilder(
        stream: alarmNotification.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // when alarm notification is selected, show dialog of vertical bar chart of alarm history
            if (snapshot.data == "payload_alarm" &&
                alarmHistory.histories.isNotEmpty) {
              WidgetsBinding.instance!.addPostFrameCallback((_) async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) =>
                      HistoryDialog(data: alarmHistory.histories),
                );
              });
              alarmNotification.addPayload(null);
            }
          }

          // build page widgets
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
                ),
              ),
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat("HH:mm").format(_tempTime),
                        style: const TextStyle(fontSize: 36),
                      ),
                      ToggleButtons(
                        children: <Widget>[
                          Text(
                            "OFF",
                            style: TextStyle(
                                color: _toggleStates[0]
                                    ? Colors.blue
                                    : Colors.black),
                          ),
                          Text(
                            "ON",
                            style: TextStyle(
                                color: _toggleStates[1]
                                    ? Colors.blue
                                    : Colors.black),
                          ),
                        ],
                        isSelected: _toggleStates,
                        onPressed: _onToggleButtonPressed,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: GestureDetector(
                      onVerticalDragStart: _onClockVerticalDragStart,
                      onVerticalDragUpdate: _onClockVerticalDragUpdate,
                      onVerticalDragEnd: _onClockVerticalDragEnd,
                      onHorizontalDragStart: _onClockHorizontalDragStart,
                      onHorizontalDragUpdate: _onClockHorizontalDragUpdate,
                      onHorizontalDragEnd: _onClockHorizontalDragEnd,
                      child: FlutterAnalogClock(
                        key: Key(_tempTime.hashCode.toString()),
                        dateTime: _tempTime,
                        isLive: false,
                        showSecondHand: false,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => alarmHistory.clearHistory(),
                    child: Text("Clear Cache"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onToggleButtonPressed(int index) {
    // if ON button is pressed, set alarm
    if (index == 1) {
      // if final datetime is before current time (in second precision), then set alarm for the next day
      DateTime alarm = _permTime.difference(DateTime.now()).inSeconds <= 0
          ? _permTime.add(Duration(days: 1))
          : _permTime;

      // set alarm
      alarmHistory.setAlarm(alarm);
      // prepare to fire alarm at destinated time
      AndroidAlarmManager.oneShotAt(
          alarm, alarmHistory.histories.length, fireAlarm);
      // delay widget state update when alarm fired
      Future.delayed(
          Duration(seconds: (alarm.difference(DateTime.now()).inSeconds)),
          _turnOffAlarm);

      // print("Alarm should be fired at ${alarm}");
    } else {
      alarmHistory.clearAlarm();
      AndroidAlarmManager.cancel(alarmHistory.histories.length);
      // print("Alarm with ID: ${alarmHistory.histories.length} is canceled.");
    }

    setState(() {
      for (int i = 0; i < _toggleStates.length; i++) {
        _toggleStates[i] = (i == index);
      }
    });
  }

  void _turnOffAlarm() {
    setState(() {
      for (int i = 0; i < _toggleStates.length; i++) {
        _toggleStates[i] = (i == 0);
      }
    });
  }

  void _onClockVerticalDragStart(DragStartDetails details) {
    setState(() {
      _startY = details.globalPosition.dy;
    });
  }

  void _onClockVerticalDragUpdate(DragUpdateDetails details) {
    double distance = _startY - details.globalPosition.dy;
    setState(() {
      _tempTime =
          _permTime.subtract(Duration(hours: distance ~/ _distanceToUpdateY));
    });
  }

  void _onClockVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _permTime = _tempTime;
    });
  }

  void _onClockHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _startX = details.globalPosition.dx;
    });
  }

  void _onClockHorizontalDragUpdate(DragUpdateDetails details) {
    double distance = _startX - details.globalPosition.dx;
    setState(() {
      _tempTime =
          _permTime.subtract(Duration(minutes: distance ~/ _distanceToUpdateX));
    });
  }

  void _onClockHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _permTime = _tempTime;
    });
  }
}

class HistoryDialog extends StatelessWidget {
  final List<int> data;

  const HistoryDialog({Key? key, required this.data})
      : assert(data.length > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(vertical: 200.0, horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              horizontalInterval: 0.5,
              drawVerticalLine: false,
              drawHorizontalLine: true,
            ),
            alignment: BarChartAlignment.spaceEvenly,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(
                showTitles: true,
              ),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return value.toInt().toString();
                },
              ),
              topTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
            ),
            barGroups: List<BarChartGroupData>.from(
              data.asMap().entries.map(
                    (e) => BarChartGroupData(
                      x: e.key.toInt(),
                      barRods: [BarChartRodData(y: e.value.toDouble())],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
