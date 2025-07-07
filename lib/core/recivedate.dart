import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class RetcivedateFromHive {
  Future<void> retriveDateFromhive(BuildContext context) async {
    if (!mybox!.isOpen || !mybox!.containsKey('timeSlots')) return;
    final List<String> savedSlots = mybox!.get('timeSlots');

    timeSlots = savedSlots;
    for (var weekContent in allWeeksContent) {
      while (weekContent.length < timeSlots.length) {
        weekContent.add(List.filled(8, const Text('')));
      }
    }

    Future<void> retriveDateFromhive() async {
      try {
        if (!mybox!.isOpen) {
          print('Hive box is not open');
          return;
        }

        if (!mybox!.containsKey('noti')) {
          print('No notifications stored');
          return;
        }

        late List<Map<String, dynamic>> noti;
        var data = mybox!.get('noti');
        if (data is List) {
          noti = List<Map<String, dynamic>>.from(data.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              // يمكنك هنا التعامل مع الحالة الغير متوقعة
              return {};
            }
          }));
        } else {
          noti = [];
        }
        final double height = MediaQuery.of(context).size.height;

        final List<Map<String, dynamic>> dataList = noti;
        notificationItemMap = dataList;

        for (final data in dataList) {
          final int week = data['week'] ?? 0;
          final int row = data['row'] ?? 1;
          final int col = data['column'] ?? 1;
          final String title = data['title'] ?? '';
          final String description = data['description'] ?? '';
          final String category = data['category'] ?? '';

          while (allWeeksContent.length <= week) {
            allWeeksContent.add(List.generate(
                timeSlots.length, (_) => List.filled(8, const Text(''))));
          }

          // Ensure week exists
          while (week >= allWeeksContent.length) {
            allWeeksContent.add(_createNewWeekContent());
          }

          // Ensure row exists
          while (row >= allWeeksContent[week].length) {
            allWeeksContent[week].add(List.filled(8, const Text('')));
          }

          // Ensure column exists
          if (col >= allWeeksContent[week][row].length) continue;

          // Recreate the original widget structure
          allWeeksContent[week][row][col] = Container(
            padding: const EdgeInsets.all(0),
            height: height * 0.13,
            width: double.infinity,
            color: _getCategoryColor(category),
            child: description.isEmpty
                ? Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          );

          // Schedule notification if time exists
          // if (title.isNotEmpty) {
          //   Notifications().scheduleNotification(
          //     id: DateTime.now().millisecondsSinceEpoch % 100000,
          //     title: title,
          //     body: description,
          //     hour: time.hour,
          //     minute: time.minute,
          //   );
          // }
        }
        // Update UI after loading all data
      } catch (e) {
        print('Error loading data: $e');
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Task':
      case 'Assignment':
        return const Color(0xffffa45b);
      case 'Exam':
        return const Color(0xffff6b6b);
      case 'Material':
        return const Color(0xff5f8cf8);
      case 'Activity':
        return const Color(0xffffe66d);
      default:
        return const Color(0xff9bb7fa);
    }
  }

  List<List<Widget>> _createNewWeekContent() {
    return List.generate(
        timeSlots.length, (_) => List.filled(8, const Text('')));
  }
}
