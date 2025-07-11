//i want to make page to test time on my device for notification scudelue
import 'package:enhud/pages/notifications/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Mytime extends StatefulWidget {
  const Mytime({super.key});

  @override
  State<Mytime> createState() => _MytimeState();
}

class _MytimeState extends State<Mytime> {
  @override
  void initState() {
    super.initState();
    initializeTime();
  }

  Future<void> initializeTime() async {
    await Notifications().initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('${DateTime.now().hour} : ${DateTime.now().minute}'),
      ),
    );
  }
}
