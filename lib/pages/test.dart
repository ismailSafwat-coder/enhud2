import 'package:enhud/main.dart';
import 'package:enhud/pages/notifications/notifications.dart';
import 'package:enhud/pages/rest.dart';
import 'package:enhud/widget/alertdialog/activity.dart';
import 'package:enhud/widget/alertdialog/anthorclass.dart';
import 'package:enhud/widget/alertdialog/assginmentdialog.dart';
import 'package:enhud/widget/alertdialog/exam.dart';
import 'package:enhud/widget/alertdialog/freetime.dart';
import 'package:enhud/widget/alertdialog/sleep.dart';
import 'package:enhud/widget/alertdialog/taskdilog.dart';
import 'package:flutter/material.dart';
import 'package:enhud/core/core.dart';

class StudyTimetable extends StatefulWidget {
  const StudyTimetable({super.key});

  @override
  State<StudyTimetable> createState() => _StudyTimetableState();
}

class _StudyTimetableState extends State<StudyTimetable> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double height;
  late double width;
  String? _priority;
  TimeOfDay? startTime;
  int id = DateTime.now().millisecondsSinceEpoch % 1000000000;
  // Track current week offset (0 = current week, 1 = next week, etc.)
  // int _currentWeekOffset = 0;

  // Store content for all weeks (week 0, week 1, etc.)
  //  allWeeksContent = [];
  //  timeSlots = [
  //   '08:00 am - 09:00 am',
  //   '09:00 am - 10:00 am',
  //   '10:00 am - 11:00 am',
  // ];

  final List<String> categories = [
    "Material",
    "Task",
    "Assignment",
    "Exam",
    "Activity",
    "sleep",
    "freetime",
    "Another Class"
  ];

  void _initNotifications() async {
    await Notifications().initNotification();
  }

  void _initializeWeeksContent() {
    // Initialize with at least one week
    if (allWeeksContent.isEmpty) {
      allWeeksContent.add(_createNewWeekContent());
    }
  }

  List<List<Widget>> _createNewWeekContent() {
    return List.generate(
        timeSlots.length, (_) => List.filled(8, const Text('')));
  }

  List<List<Widget>> get _currentWeekContent {
    // Ensure we have content for the current week
    while (currentWeekOffset >= allWeeksContent.length) {
      allWeeksContent.add(_createNewWeekContent());
    }
    return allWeeksContent[currentWeekOffset];
  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekOffset--;
      if (currentWeekOffset < 0) {
        currentWeekOffset = 0; // Don't go before week 0
      }
    });
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekOffset++;
    });
  }

  String _getWeekTitle() {
    if (currentWeekOffset == 0) {
      return 'Current Week';
    } else if (currentWeekOffset == 1) {
      return 'Next Week';
    } else if (currentWeekOffset == -1) {
      return 'Last Week';
    } else if (currentWeekOffset > 1) {
      return 'In $currentWeekOffset Weeks';
    } else {
      return '${-currentWeekOffset} Weeks Ago';
    }
  }

  Future<void> _addNewTimeSlot() async {
    startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime!,
    );

    if (endTime == null) return;

    final String newTimeSlot =
        '${startTime!.format(context)} - ${endTime.format(context)}';

    setState(() {
      timeSlots.add(newTimeSlot);
      // Add new row to all weeks
      for (var weekContent in allWeeksContent) {
        weekContent.add(List.filled(8, const Text('')));
      }
    });
    _saveTimeSlots();
  }

  // Future<void> pickTimeAndScheduleNotification(
  //   String Timeslote,
  //   BuildContext context,
  //   String title,
  //   String body,
  // ) async {
  //   if (startTime != null) {
  //     Notifications().scheduleNotification(
  //       id: 2,
  //       title: title,
  //       body: body,
  //       hour: startTime!.hour,
  //       minute: startTime!.minute,
  //     );
  //   }
  // }

  Future<void> pickTimeAndScheduleNotification(
      String timeSlot, BuildContext context, String title, String body) async {
    // استخراج الجزء الأول من الوقت فقط (مثلاً "08:00 am")
    String rawTime = _extractFirstTime(timeSlot);

    // تحويل النص إلى TimeOfDay
    TimeOfDay? parsedTime = parseTime(rawTime);

    if (parsedTime != null) {
      // جدولة الإشعار
      Notifications().scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch % 1000000000, // ID فريد
        title: title,
        body: body,
        hour: parsedTime.hour,
        minute: parsedTime.minute,
      );

      // يمكنك إضافة Toast أو SnackBar للتأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم جدولة الإشعار عند $rawTime')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في قراءة الوقت')),
      );
    }
  }

  Future<void> storeEoHive(Map<String, dynamic> newData) async {
    try {
      // 1. التحقق من أن الصندوق مفتوح وموجود
      if (!mybox!.isOpen) {
        throw Exception('Hive box is not open');
      }

      // 2. جلب البيانات الحالية أو إنشاء قائمة جديدة إذا لم تكن موجودة
      List<Map<String, dynamic>> currentList = mybox!.containsKey('noti')
          ? List.from(mybox!.get('noti')) // إنشاء نسخة جديدة من القائمة
          : [];

      // 3. إضافة البيانات الجديدة
      currentList.add(newData);

      // 4. حفظ القائمة المحدثة
      await mybox!.put('noti', currentList);

      print('تم تخزين البيانات بنجاح: $newData');
    } catch (e) {
      print('حدث خطأ أثناء التخزين: $e');
      rethrow; // يمكنك التعامل مع الخطأ في مكان آخر إذا لزم الأمر
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

      setState(() {}); // Update UI after loading all data
    } catch (e) {
      print('Error loading data: $e');
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

  Future<void> _saveTimeSlots() async {
    if (!mybox!.isOpen) return;
    await mybox!.put('timeSlots', timeSlots);
  }

  Future<void> _loadTimeSlots() async {
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

  String _extractFirstTime(String timeSlot) {
    // تقسيم النص عند " - " وأخذ الجزء الأول
    return timeSlot.split(' - ').first.trim();
  }

  TimeOfDay? parseTime(String timeString) {
    // مثال: '08:00 am'
    final RegExp timeRegex =
        RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)', caseSensitive: false);
    final Match? match = timeRegex.firstMatch(timeString.toLowerCase());

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!;

      if (period == 'pm' && hour != 12) {
        hour += 12;
      } else if (period == 'am' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }
    return null; // إذا لم يتطابق التنسيق
  }

  @override
  void initState() {
    super.initState();
    RestartWidget.restartApp(context);
    _initNotifications();
    _initializeWeeksContent();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTimeSlots();
      await retriveDateFromhive();
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.sizeOf(context).height;
    width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              mybox!.delete('noti');
              mybox!.delete('timeSlots');
              print('noti and timeSlots deleted ');
            });
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _goToPreviousWeek,
            ),
            Text(_getWeekTitle()),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _goToNextWeek,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xffE4E4E4),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: Colors.white, width: 2),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(1),
                      6: FlexColumnWidth(1),
                      7: FlexColumnWidth(1),
                    },
                    children: [
                      _buildTableHeader(),
                      for (int i = 0; i < timeSlots.length; i++)
                        _buildTableRow(timeSlots[i], rowIndex: i),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _addNewTimeSlot,
                  child: Container(
                    height: 50,
                    width: width * 0.25,
                    color: Colors.blue[100],
                    child: const Center(
                      child: Icon(Icons.add_circle, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildTableCell('Day / Time', isHeader: true),
        _buildTableCell('Sat', isHeader: true, addpadding: true),
        _buildTableCell('Sun', isHeader: true, addpadding: true),
        _buildTableCell('Mon', isHeader: true, addpadding: true),
        _buildTableCell('Tue', isHeader: true, addpadding: true),
        _buildTableCell('Wed', isHeader: true, addpadding: true),
        _buildTableCell('Thu', isHeader: true, addpadding: true),
        _buildTableCell('Fri', isHeader: true, addpadding: true),
      ],
    );
  }

  TableRow _buildTableRow(String time, {required int rowIndex}) {
    return TableRow(
      children: [
        _buildTableCell(time, isrowheder: true),
        for (int colIndex = 1; colIndex < 8; colIndex++)
          _buildTableCellWithGesture(rowIndex, colIndex),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false,
      bool isrowheder = false,
      bool addpadding = false}) {
    return Container(
      height: height * 0.12,
      color:
          isHeader || isrowheder ? Colors.blue[100] : const Color(0xffE4E4E4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCellWithGesture(int rowIndex, int colIndex) {
    return GestureDetector(
      onTap: () {
        _showAddItemDialog(rowIndex, colIndex);
      },
      child: Container(
        color: const Color(0xffE4E4E4),
        child: Center(
          child: _currentWeekContent[rowIndex][colIndex],
        ),
      ),
    );
  }

  void _showAddItemDialog(int rowIndex, int colIndex) {
    String? selectedCategory;
    TextEditingController taskController = TextEditingController();
    TextEditingController Descriptioncontroller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          backgroundColor: const Color(0xfff8f7f7),
          contentPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xffc6c6c6)),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.99,
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        selectedCategory == null
                            ? const Text('Select Category')
                            : selectedCategory == 'sleep'
                                ? const Text(
                                    'Sleep Schedule',
                                    style: commonTextStyle,
                                  )
                                : selectedCategory == 'freetime'
                                    ? const Text(
                                        'Free Time Planner',
                                        style: commonTextStyle,
                                      )
                                    : selectedCategory == 'Another Class'
                                        ? const Text(
                                            'Add Your Class',
                                            style: commonTextStyle,
                                          )
                                        : Text('add New $selectedCategory'),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xffc6c6c6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        hint: const Text('Select'),
                        value: selectedCategory,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Dynamic fields based on category
                  if (selectedCategory == 'Task') ...[
                    Taskdilog(
                        type: 'Task',
                        priority: _priority,
                        formKey: _formKey,
                        taskController: taskController,
                        Descriptioncontroller: Descriptioncontroller,
                        onPriorityChanged: (value) {
                          setDialogState(() => _priority = value);
                        })
                  ] else if (selectedCategory == 'Assignment') ...[
                    AssignmentDialog(
                      type: 'Assignment',
                      formKey: _formKey,
                      taskController: taskController,
                      Descriptioncontroller: Descriptioncontroller,
                    )
                  ] else if (selectedCategory == 'Activity') ...[
                    ActivityDialog(
                      type: 'Activity',
                      formKey: _formKey,
                      taskController: taskController,
                      Descriptioncontroller: Descriptioncontroller,
                    )
                  ] else if (selectedCategory == 'Material') ...[
                    AssignmentDialog(
                      type: 'Material',
                      formKey: _formKey,
                      taskController: taskController,
                      Descriptioncontroller: Descriptioncontroller,
                    )
                  ] else if (selectedCategory == 'Exam') ...[
                    ExamDialog(
                      type: 'Exam',
                      formKey: _formKey,
                      taskController: taskController,
                      Descriptioncontroller: Descriptioncontroller,
                    )
                  ] else if (selectedCategory == 'Another Class') ...[
                    Anthorclass(
                      taskController: taskController,
                      Descriptioncontroller: Descriptioncontroller,
                    )
                  ] else if (selectedCategory == 'sleep') ...[
                    const Sleep()
                  ] else if (selectedCategory == 'freetime') ...[
                    const Freetime()
                  ],

                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        if (taskController.text.isNotEmpty) {
                          pickTimeAndScheduleNotification(
                            timeSlots[rowIndex],
                            context,
                            taskController.text,
                            Descriptioncontroller.text,
                          );

                          Map<String, dynamic> notificationInfotoStore = {
                            'id': id,
                            "weeknumber": DateTime.now().weekday,
                            "daynumber": DateTime.now().day,
                            "week": currentWeekOffset,
                            "row": rowIndex,
                            'column': colIndex,
                            "title": taskController.text.trim(),
                            "description": Descriptioncontroller.text.trim(),
                            "category": selectedCategory,
                            "done": false,
                            "time": _extractFirstTime(timeSlots[rowIndex]),
                          };
                          storeEoHive(notificationInfotoStore);
                          // Update the current week's content
                          allWeeksContent[currentWeekOffset][rowIndex]
                              [colIndex] = Container(
                            padding: const EdgeInsets.all(0),
                            height: height * 0.13,
                            width: double.infinity,
                            color: selectedCategory == 'Task'
                                ? const Color(0xffffa45b)
                                : selectedCategory == 'Assignment'
                                    ? const Color(0xffffa45b)
                                    : selectedCategory == 'Exam'
                                        ? const Color(0xffff6b6b)
                                        : selectedCategory == 'Material'
                                            ? const Color(0xff5f8cf8)
                                            : selectedCategory == 'Activity'
                                                ? const Color(0xffffe66d)
                                                : const Color(0xff9bb7fa),
                            child: Descriptioncontroller.text.isEmpty
                                ? Center(
                                    child: Text(
                                      taskController.text,
                                      style: commonTextStyle,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        taskController.text,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Wrap(
                                        children: [
                                          Text(
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            Descriptioncontroller.text,
                                            maxLines: 3,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                          );
                        } else if (taskController.text.isEmpty &&
                            Descriptioncontroller.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              content: Text('please filled required filled'),
                            ),
                          );
                          // Show the time picker
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: selectedCategory == 'sleep' ||
                              selectedCategory == 'freetime' ||
                              selectedCategory == 'Another Class'
                          ? const Text('Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18))
                          : selectedCategory == null
                              ? const Text(
                                  'Add',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : Text('Add $selectedCategory',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
