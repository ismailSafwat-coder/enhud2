import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Todayschedule extends StatefulWidget {
  const Todayschedule({super.key});

  @override
  State<Todayschedule> createState() => _TodayscheduleState();
}

class _TodayscheduleState extends State<Todayschedule> {
  List<Map<String, dynamic>> todayNotifications = [];

  loaddata() async {
    User currentUser = FirebaseAuth.instance.currentUser!;

    if (mybox == null || !mybox!.isOpen) {
      print('Hive box is not open');
      //open hive box

      mybox = await openHiveBox(currentUser.uid);
      print('Hive box is open');
    }

    var data = mybox!.get('noti');
    // print('Retrieved data from Hive: $data');

    if (data is List) {
      notificationItemMap = List<Map<String, dynamic>>.from(data.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          return {};
        }
      }));

      // print('Parsed notificationItemMap: $notificationItemMap');

      // Filter notifications for today
      DateTime now = DateTime.now();
      int today = now.weekday; // 1 = Monday, 7 = Sunday
      // print('Today is weekday: $today');

      // Map column index to weekday
      Map<int, int> columnToWeekday = {
        1: 3, // Saturday
        2: 4, // Sunday
        3: 5, // Monday
        4: 6, // Tuesday
        5: 7, // Wednesday
        6: 2, // Thursday
        7: 1, // Friday
      };

      todayNotifications = notificationItemMap.where((item) {
        // Debug prints
        // print('Checking item: $item');
        // print(
        //     'Item week: ${item['week']}, currentWeekOffset: $currentWeekOffset');
        // print(
        //     'Item column: ${item['column']}, mapped to weekday: ${columnToWeekday[today]}');

        // Check if the notification is for the current week
        bool isCurrentWeek = item['week'] == currentWeekOffset;

        // Check if the column matches today's weekday
        int column = item['column'] ?? 0;
        bool isToday = columnToWeekday[today] == column;

        // print('Is current week: $isCurrentWeek, Is today: $isToday');

        return isCurrentWeek && isToday;
      }).toList();

      // print('Filtered todayNotifications: $todayNotifications');
    } else {
      notificationItemMap = [];
      todayNotifications = [];
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    return todayNotifications.isEmpty
        ? const Center(
            child: Text(
              'There is no schedule today',
              style: midTextStyle,
            ),
          )
        : SizedBox(
            height: deviceheight * 0.37,
            width: double.infinity,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Today Schedule :',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: todayNotifications.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            mycard(todayNotifications, index),
                          ],
                        );
                      }),
                ),
              ],
            ),
          );
  }

  String _getRemainingTime(String scheduledTimeStr) {
    // Parse the scheduled time (e.g., "09:00 am")
    TimeOfDay? scheduledTime = _parseTimeString(scheduledTimeStr);
    if (scheduledTime == null) {
      return 'Invalid time';
    }

    // Get current time
    DateTime now = DateTime.now();

    // Create a DateTime for the scheduled time today
    DateTime scheduledDateTime = DateTime(
        now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);

    // If the scheduled time is already passed for today
    if (scheduledDateTime.isBefore(now)) {
      return '  Passed';
    }

    // Calculate the difference
    Duration difference = scheduledDateTime.difference(now);

    // Format the remaining time
    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;

    return '${hours}hrs ${minutes}mins';
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Handle formats like "09:00 am" or "9:00 am"
      timeStr = timeStr.toLowerCase().trim();
      bool isPM = timeStr.contains('pm');

      // Remove am/pm and trim
      timeStr = timeStr.replaceAll('am', '').replaceAll('pm', '').trim();

      // Split hours and minutes
      List<String> parts = timeStr.split(':');
      if (parts.length != 2) return null;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Convert to 24-hour format if PM
      if (isPM && hour < 12) {
        hour += 12;
      }
      // Convert 12 AM to 0
      if (!isPM && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }

  SizedBox mycard(List<Map<String, dynamic>> noti, int index) {
    return SizedBox(
        height: deviceheight * 0.25,
        width: devicewidth * 0.9,
        child: Card(
          margin: const EdgeInsets.all(8),
          color: const Color(0xFF5f8cf8),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //fist row
                Row(
                  children: [
                    const Text(
                      'Up Coming',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(
                      width: 70,
                    ),
                    Row(
                      children: [
                        Image.asset('images/timer.png'),
                        Text(
                          _getRemainingTime(noti[index]['time']),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        )
                      ],
                    )
                  ],
                ),
                //secound row
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    //image
                    Image.asset(
                      'images/teacherpic.png',
                      fit: BoxFit.fill,
                      height: deviceheight * 0.1,
                      width: devicewidth * 0.17,
                    ),
                    //column teacher and material
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " Teacher :${noti[index][description]}",
                            style: const TextStyle(
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                            maxLines: 1,
                          ),
                          Text(
                            ' ${noti[index]['category']} : ${noti[index]['title']}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                //text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      fit: BoxFit.fill,
                      'images/clock1.png',
                      width: 20,
                      height: 20,
                    ),
                    Text(
                      ' ${noti[index]['time']}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
