// file: notifications_screen.dart
import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, String> motivationmessges = {
    "Material": 'You should go now so you won\'t be late',
    "Task":
        "You should solve the set of problems the theacher has requested in the last lesson now",
    "Assignment":
        "You should start in the project now to be able to meet the deadline.",
    "Exam":
        "You have an exam in physics tomorrow, You should start studying and revising well from now.",
    "Activity": "You should go to gym now, Don't belazy to keep your fit.",
    "sleep": "",
    "freetime": "",
    "Another Class": ""
  };

  @override
  void initState() {
    super.initState();
    var data = mybox!.get('noti');

    if (data is List) {
      notificationItemMap = List<Map<String, dynamic>>.from(data.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          // يمكنك هنا التعامل مع الحالة الغير متوقعة
          return {};
        }
      }));
    } else {
      notificationItemMap = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.black),
            SizedBox(width: 8),
            Text("Notifications", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: notificationItemMap.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationItemMap.length,
              itemBuilder: (context, index) {
                return NotificationCard(
                    notification: notificationItemMap[index],
                    noti: notificationItemMap);
              },
            ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final List<Map<String, dynamic>> noti;

  const NotificationCard(
      {super.key, required this.notification, required this.noti});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.notification['category'] == 'Task'
            ? const Color(0xffffa45b)
            : widget.notification['category'] == 'Assignment'
                ? const Color(0xffffa45b)
                : widget.notification['category'] == 'Exam'
                    ? const Color(0xffff6b6b)
                    : widget.notification['category'] == 'Material'
                        ? const Color(0xff5f8cf8)
                        : widget.notification['category'] == 'Activity'
                            ? const Color(0xffffe66d)
                            : const Color(0xff9bb7fa),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("• ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                widget.notification['title'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text("  •  "),
              Text(widget.notification['category'] ?? '',
                  style: const TextStyle(fontSize: 14)),
              const Spacer(),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(widget.notification['time'] ?? '',
                  // "3",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            getmotivationmessage(
                widget.notification['category'], widget.notification['title']),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (widget.notification['done'] == true) {
                    widget.notification['done'] = false;
                    setState(() {});
                    mybox!.put('noti', widget.noti);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Notification marked as undone"),
                        duration: Duration(seconds: 2)));
                    return;
                  }
                  // Mark notification as done
                  widget.notification['done'] = true;
                  setState(() {});
                  mybox!.put('noti', widget.noti);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Notification marked as done"),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            widget.notification['done'] = false;
                            setState(() {});

                            mybox!.put('noti', widget.noti);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Notification marked as undone"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          })));
                },
                child: Text(
                    widget.notification['done'] == true ? "undo" : "Done",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {},
                child: const Text("Snooze",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color getColorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'orange':
      return Colors.orange.shade300;
    case 'red':
      return Colors.red.shade300;
    case 'blue':
      return Colors.blue.shade300;
    case 'yellow':
      return Colors.yellow.shade300;
    default:
      return Colors.grey.shade300;
  }
}

String getmotivationmessage(String caregory, String title) {
  switch (caregory.toLowerCase()) {
    case 'Material':
      return 'You should go now so you won\'t be late';
    case 'Exam':
      return 'You have an exam in physics tomorrow, You should start studying and revising well from now.';
    case 'task':
      return 'You should solve the set of problems the theacher has requested in the last lesson now';
    case 'Assignment':
      return 'You should start in the project now to be able to meet the deadline.';
    case 'Activity':
      return 'You should go to gym now, Don\'t belazy to keep your fit.';

    default:
      return 'good';
  }
}
