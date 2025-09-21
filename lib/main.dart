import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kikin/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiKin',
      theme: WorkAppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: Text('KiKin')),
        body: Container(
          color: Colors.grey[200],
          child: Column(children: [_CurrentTimeCard()]),
        ),
      ),
    );
  }
}

class _CurrentTimeCard extends StatefulWidget {
  const _CurrentTimeCard();

  @override
  State<_CurrentTimeCard> createState() => _CurrentTimeCardState();
}

class _CurrentTimeCardState extends State<_CurrentTimeCard> {
  String? _hourMinuteSecond;
  String? _yearMonthDay;
  String? _weekDay;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _updateWeekDay();
  }

  void _updateCurrentTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final currentTime = DateTime.now();
        _yearMonthDay =
            '${currentTime.year.toString().padLeft(4, '0')}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}';
        _hourMinuteSecond =
            '${currentTime.hour.toString().padLeft(2, '0')} : ${currentTime.minute.toString().padLeft(2, '0')} : ${currentTime.second.toString().padLeft(2, '0')}';
      });
    });
  }

  void _updateWeekDay() {
    setState(() {
      _weekDay = DateTime.now().weekday.toString();
      switch (_weekDay) {
        case '1':
          _weekDay = '周一';
          break;
        case '2':
          _weekDay = '周二';
          break;
        case '3':
          _weekDay = '周三';
          break;
        case '4':
          _weekDay = '周四';
          break;
        case '5':
          _weekDay = '周五';
          break;
        case '6':
          _weekDay = '周六';
          break;
        case '7':
          _weekDay = '周日';
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          children: [
            Text(_hourMinuteSecond ?? '', style: TextStyle(fontSize: 24)),
            Text(
              '$_yearMonthDay ($_weekDay)',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
