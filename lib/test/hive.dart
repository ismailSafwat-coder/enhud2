import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class HiveTestPage extends StatefulWidget {
  const HiveTestPage({super.key});

  @override
  State<HiveTestPage> createState() => _HiveState();
}

class _HiveState extends State<HiveTestPage> {
  List<Map<String, dynamic>> putdate = [
    {"type": 'task'},
    {'value': 5}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () async {
                await mybox!.put('noti', putdate);
                print('the date pute secucfuly');
              },
              child: const Text('put data with hive'),
            ),
            MaterialButton(
              onPressed: () {
                if (!mybox!.isOpen) {
                  print('Hive box is not open');
                } else if (!mybox!.containsKey('noti')) {
                  print('Key "noti" does not exist in the box');
                } else {
                  List<Map<String, dynamic>> result = mybox!.get('noti');
                  print('Data retrieved successfully: $result');
                }
              },
              child: const Text('get data with hive'),
            ),
            MaterialButton(
              onPressed: () {
                mybox!.delete('noti');
                mybox!.delete('timeslots');
                print('the date deleted secucfuly');
              },
              child: const Text('delete data with hive'),
            ),
          ],
        ),
      ),
    );
  }
}
