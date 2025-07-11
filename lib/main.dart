import 'package:enhud/core/core.dart';
import 'package:enhud/firebase_options.dart';

import 'package:enhud/pages/authpages/loginpage.dart';
import 'package:enhud/pages/homescreen.dart';
import 'package:enhud/pages/notifications/notifications.dart';
import 'package:enhud/test/mytime.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

Box? mybox;
late double deviceheight;
late double devicewidth;
late int currentWeekOffset;

Future<Box?> openHiveBox(String boxname) async {
  if (!Hive.isBoxOpen(boxname)) {
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }
  return await Hive.openBox(boxname);
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();

  // Init Hive early
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Init notifications
  await Notifications().initNotification();

  // Get current user safely
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Only proceed with user-specific operations if user exists
  if (currentUser != null) {
    print('-------------User is signed in!');
    print('====================${currentUser.uid}');
    // Open Hive box for current user
    mybox = await openHiveBox(currentUser.uid);

    // Check if this is first time opening app (no week tracking data)
    if (!mybox!.containsKey('weekStartDate')) {
      // Store initial week data
      await mybox!.put('weekStartDate', DateTime.now().millisecondsSinceEpoch);
      await mybox!.put('currentWeekOffset', 0);
    } else {
      // Calculate weeks passed since first use
      int startDateMillis = mybox!.get('weekStartDate');
      DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      DateTime now = DateTime.now();

      // Calculate difference in weeks (integer division)
      int weeksPassed = now.difference(startDate).inDays ~/ 7;

      // Update the current week offset
      await mybox!.put('currentWeekOffset', weeksPassed);
    }

    // Set the global currentWeekOffset from Hive
    currentWeekOffset = mybox!.get('currentWeekOffset') ?? 0;
    print(currentWeekOffset);
  } else {
    print('-------------No user signed in');
  }

  // Run the app
  runApp(const MyApp());
}

const TextStyle midTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w500,
  color: Colors.black,
);
const TextStyle commonTextStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w500,
  color: Colors.black,
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    deviceheight = MediaQuery.sizeOf(context).height;
    devicewidth = MediaQuery.sizeOf(context).width;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ُenhud',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: //
            // const Mytime(),
            AnimatedSplashScreen(
                duration: 7000,
                centered: true,
                splashIconSize: 5000,
                splash: "images/enhudintro-ezgif.com-resize.gif",
                nextScreen: FirebaseAuth.instance.currentUser != null
                    ? const HomeScreen()
                    : const LoginPage())

        // const HiveTestPage(),
        );
  }
}

// class ExamApp extends StatelessWidget {
//   const ExamApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Exam Generator',
//       theme: ThemeData(
//           primaryColor: AppColors.primary,
//           scaffoldBackgroundColor: AppColors.background,
//           fontFamily: 'Cairo',
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo'),
//             ),
//           ),
//           outlinedButtonTheme: OutlinedButtonThemeData(
//               style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.primary,
//             side: const BorderSide(color: AppColors.primary),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             textStyle: const TextStyle(
//                 fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
//           )),
//           appBarTheme: const AppBarTheme(
//               backgroundColor: AppColors.background,
//               elevation: 0,
//               centerTitle: true,
//               iconTheme: IconThemeData(color: AppColors.textDark),
//               titleTextStyle: TextStyle(
//                   color: AppColors.textDark,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo'))),
//       home: const GenerationHomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }



