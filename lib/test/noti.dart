// import 'dart:async';

// import 'package:enhud/pages/notifications/notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class Noti extends StatefulWidget {
//   const Noti({super.key});

//   @override
//   State<Noti> createState() => _NotiState();
// }

// class _NotiState extends State<Noti> {
//   late StreamSubscription<NotificationResponse> _notificationSubscription;

//   @override
//   void initState() {
//     super.initState();

//     // Listen to notification actions
//     _notificationSubscription = Notifications()
//         .notificationResponseStream
//         .listen(_handleNotificationAction);
//   }

//   void _handleNotificationAction(NotificationResponse response) {
//     // Handle the action in your UI
//     if (response.actionId == '1') {
//       // Done action
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Task marked as done!'),
//       ));
//     } else if (response.actionId == '2') {
//       // Snooze action
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Task snoozed for 10 minutes'),
//       ));
//     }
//   }

//   @override
//   void dispose() {
//     _notificationSubscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 Notifications().showNotification(
//                   title: 'Title',
//                   body: 'body',
//                 );
//               },
//               child: const Text('show notification'),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // Show the time picker
//               TimeOfDay? pickedTime = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.now(),
//               );

//               if (pickedTime != null) {
//                 // Schedule the notification with picked time
//                 Notifications().scheduleNotification(
//                   id: 4,
//                   title: 'Scheduled Notification',
//                   body: 'This is a scheduled notification',
//                   hour: pickedTime.hour,
//                   minute: pickedTime.minute,
//                 );
//               }
//             },
//             child: const Text('schedule notification'),s
//           ),
//         ],
//       ),
//     );
//   }
// }
