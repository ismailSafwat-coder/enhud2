import 'package:enhud/core/core.dart';
import 'package:enhud/core/recivedate.dart';
import 'package:enhud/main.dart';
import 'package:enhud/pages/homepage.dart';
import 'package:enhud/pages/notificationscreen.dart';
import 'package:enhud/pages/settingsscreen.dart';
import 'package:enhud/pages/studeytablepage.dart';
import 'package:enhud/pages/timetable.dart';
import 'package:enhud/screens/0_generation_home_screen.dart';
import 'package:enhud/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  final int? homeindex;

  const HomeScreen({super.key, this.homeindex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> pages = ['Home', 'Timetable', 'Add', 'Exam', 'Settings'];
  int index = 0;
  List<Widget> screens = [
    const Homepage(),
    const Studeytablepage(),
    const StudyTimetable(),
    const GenerationHomeScreen(),
    const SettingsScreen()
  ];
  @override
  @override
  void initState() {
    index = widget.homeindex ?? index;
    // Initialize the Hive box to retrieve data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTimeSlots();
      await retriveDateFromhive();
      await _loadCurrentWeekOffset();
    });

    super.initState();
  }

  Future<void> _loadCurrentWeekOffset() async {
    if (mybox != null &&
        mybox!.isOpen &&
        mybox!.containsKey('currentWeekOffset')) {
      setState(() {
        currentWeekOffset = mybox!.get('currentWeekOffset');
      });
    } else {
      currentWeekOffset = 0;
    }
  }

  List<List<Widget>> _createNewWeekContent() {
    return List.generate(
        timeSlots.length, (_) => List.filled(8, const Text('')));
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

  Future<void> _loadTimeSlots() async {
    mybox ??= await openHiveBox(FirebaseAuth.instance.currentUser!.uid);

    // Then proceed with your existing code, with additional null checks
    if (mybox != null && mybox!.isOpen) {
      // Your existing code
      if (!mybox!.isOpen || !mybox!.containsKey('timeSlots')) return;

      final List<String> savedSlots = mybox!.get('timeSlots');
      setState(() {
        timeSlots = savedSlots;
        // Initialize content for all weeks based on loaded time slots
        for (var weekContent in allWeeksContent) {
          while (weekContent.length < timeSlots.length) {
            weekContent.add(List.filled(8, const Text('')));
          }
        }
      });
    }
  }

  Future<void> retriveDateFromhive() async {
    User currentUser = FirebaseAuth.instance.currentUser!;
    try {
      if (!mybox!.isOpen) {
        print('Hive box is not open');
        //open hive box

        mybox = await openHiveBox(currentUser.uid);
        print('Hive box is open');
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
      }

      setState(() {}); // Update UI after loading all data
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[index],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFbfbfbf)),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                if (index == 0) {
                } else {
                  setState(() {
                    index = 0;
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('images/Home.svg'),
                  if (pages[index] == 'Home')
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5f8cf8),
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (index == 1) {
                } else {
                  setState(() {
                    index = 1;
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('images/Timetable.svg'),
                  if (pages[index] == 'Timetable')
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5f8cf8),
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (index == 2) {
                } else {
                  setState(() {
                    index = 2;
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('images/Add.svg'),
                  if (pages[index] == 'Add')
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5f8cf8),
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (index == 3) {
                } else {
                  setState(() {
                    index = 3;
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('images/Exam.svg'),
                  if (pages[index] == 'Exam')
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (index == 4) {
                } else {
                  setState(() {
                    index = 4;
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset('images/Settings.svg'),
                  if (pages[index] == 'Settings')
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5f8cf8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
