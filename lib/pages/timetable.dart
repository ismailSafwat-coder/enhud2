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
import 'package:firebase_auth/firebase_auth.dart';
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
  String _priority = "Medium";
  TimeOfDay? startTime;
  int id = DateTime.now().millisecondsSinceEpoch % 1000000000;
  // Track current week offset (0 = current week, 1 = next week, etc.)
  // int _currentWeekOffset = 0;

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
      // Save to Hive
      if (mybox != null && mybox!.isOpen) {
        mybox!.put('currentWeekOffset', currentWeekOffset);
      }
    });
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekOffset++;
      // Save to Hive
      if (mybox != null && mybox!.isOpen) {
        mybox!.put('currentWeekOffset', currentWeekOffset);
      }
    });
  }

  openmybox() async {
    mybox = await openHiveBox(FirebaseAuth.instance.currentUser!.uid);
  }

  openweekstart() async {
    // Store initial week data
    await mybox!.put('weekStartDate', DateTime.now().millisecondsSinceEpoch);
    await mybox!.put('currentWeekOffset', 0);
  }

  String _getWeekTitle() {
    //open box if not open
    if (mybox == null || !mybox!.isOpen) {
      openmybox();
      return 'Current Week'; // Default if box isn't available
    }
    // Get the current weeksPassed value
    if (!mybox!.containsKey('weekStartDate')) {
      // Store initial week data
      openweekstart();
    }
    int startDateMillis = mybox!.get('weekStartDate');
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
    DateTime now = DateTime.now();
    int weeksPassed = now.difference(startDate).inDays ~/ 7;

    if (currentWeekOffset == weeksPassed) {
      return 'Current Week';
    } else if (currentWeekOffset > weeksPassed) {
      int weeksAhead = currentWeekOffset - weeksPassed;
      return '$weeksAhead ${weeksAhead == 1 ? 'Week' : 'Weeks'} Ahead';
    } else {
      int weeksAgo = weeksPassed - currentWeekOffset;
      return '$weeksAgo ${weeksAgo == 1 ? 'Week' : 'Weeks'} Ago';
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

  void _showTimeSlotOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage Time Slot',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeSlots[index],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Time Slot'),
              onTap: () {
                Navigator.pop(context);
                _editTimeSlot(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Time Slot'),
              onTap: () {
                Navigator.pop(context);
                _deleteTimeSlot(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTimeSlot(int index) async {
    // Parse current time slot
    List<String> parts = timeSlots[index].split(' - ');
    String startStr = parts[0];
    String endStr = parts[1];

    // Convert to TimeOfDay
    TimeOfDay? initialStart = parseTime(startStr);
    TimeOfDay? initialEnd = parseTime(endStr);

    if (initialStart == null || initialEnd == null) {
      initialStart = TimeOfDay.now();
      initialEnd =
          TimeOfDay(hour: initialStart.hour + 1, minute: initialStart.minute);
    }

    // Get new start time
    final TimeOfDay? newStart = await showTimePicker(
      context: context,
      initialTime: initialStart,
    );

    if (newStart == null) return;

    // Get new end time
    final TimeOfDay? newEnd = await showTimePicker(
      context: context,
      initialTime: newStart,
    );

    if (newEnd == null) return;

    // Update time slot
    setState(() {
      timeSlots[index] =
          '${newStart.format(context)} - ${newEnd.format(context)}';
    });

    _saveTimeSlots();
  }

  void _deleteTimeSlot(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Slot'),
        content: Text('Are you sure you want to delete "${timeSlots[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() {
                timeSlots.removeAt(index);
                // Remove corresponding row from all weeks
                for (var weekContent in allWeeksContent) {
                  if (index < weekContent.length) {
                    weekContent.removeAt(index);
                  }
                }
              });
              _saveTimeSlots();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> pickTimeAndScheduleNotification(
      String timeSlot, BuildContext context, String title, String body,
      {required int rowIndex, required int colIndex}) async {
    // Extract the first time from the time slot
    String rawTime = _extractFirstTime(timeSlot);

    // Parse the time
    TimeOfDay? parsedTime = parseTime(rawTime);

    if (parsedTime != null) {
      // Schedule the notification using week, row, column format
      await Notifications().scheduleNotification(
        week: currentWeekOffset,
        row: rowIndex,
        column: colIndex,
        title: title,
        body: body,
        hour: parsedTime.hour,
        minute: parsedTime.minute,
      );

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'تم اضافته يوم ${_getDayName(colIndex)} الساعه: $rawTime',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ),
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
      List<dynamic> currentList = [];
      if (mybox!.containsKey('noti')) {
        var storedData = mybox!.get('noti');
        if (storedData is List) {
          currentList = storedData;
        }
      }

      // 3. إضافة البيانات الجديدة
      currentList.add(newData);

      // 4. حفظ القائمة المحدثة
      await mybox!.put('noti', currentList);

      // 5. Also update the week tracking data
      await mybox!
          .put('lastUpdateTimestamp', DateTime.now().millisecondsSinceEpoch);
      await mybox!.put('currentWeekOffset', currentWeekOffset);

      print('تم تخزين البيانات بنجاح: $newData');
    } catch (e) {
      print('حدث خطأ أثناء التخزين: $e');
      rethrow; // يمكنك التعامل مع الخطأ في مكان آخر إذا لزم الأمر
    }
  }

  Future<void> _saveTimeSlots() async {
    if (!mybox!.isOpen) return;
    await mybox!.put('timeSlots', timeSlots);
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
    _loadCurrentWeekOffset();
    _checkAndUpdateWeekOffset(); // Add this line to check for week changes
  }

  Future<void> _loadCurrentWeekOffset() async {
    if (mybox != null &&
        mybox!.isOpen &&
        mybox!.containsKey('currentWeekOffset')) {
      setState(() {
        currentWeekOffset = mybox!.get('currentWeekOffset');
      });
    }
  }

  Future<void> _checkAndUpdateWeekOffset() async {
    if (mybox != null && mybox!.isOpen) {
      // Get the last update timestamp
      if (mybox!.containsKey('lastUpdateTimestamp')) {
        int lastUpdateTimestamp = mybox!.get('lastUpdateTimestamp');
        DateTime lastUpdate =
            DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);
        DateTime now = DateTime.now();

        // Calculate weeks passed since last update
        int daysPassed = now.difference(lastUpdate).inDays;
        int weeksPassed = daysPassed ~/ 7;

        if (weeksPassed > 0) {
          // Update currentWeekOffset
          setState(() {
            currentWeekOffset += weeksPassed;
            print('Weeks passed: $weeksPassed, new offset: $currentWeekOffset');
          });

          // Store new values in Hive
          await mybox!.put('currentWeekOffset', currentWeekOffset);
          await mybox!.put('lastUpdateTimestamp', now.millisecondsSinceEpoch);
        }
      } else {
        // First time storing timestamp
        await mybox!
            .put('lastUpdateTimestamp', DateTime.now().millisecondsSinceEpoch);
        await mybox!.put('currentWeekOffset', currentWeekOffset);
      }
    }
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
            currentWeekOffset == 0
                ? const SizedBox()
                : IconButton(
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
        GestureDetector(
          onLongPress: () => _showTimeSlotOptions(rowIndex),
          child: _buildTableCell(time, isrowheder: true),
        ),
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
    /// Returns true if the cell at [row],[col] is the default empty Text('')
    bool isCellEmpty(int row, int col) {
      final widget = _currentWeekContent[row][col];
      return widget is Text && (widget.data?.trim().isEmpty ?? true);
    }

    return GestureDetector(
      onTap: () {
        // i wnat to make sure that the cell is empety
        if (isCellEmpty(rowIndex, colIndex)) {
          _showAddItemDialog(rowIndex, colIndex);
        } else {}
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
              'What do you want to do?',
              style: commonTextStyle,
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddItemDialog(rowIndex, colIndex);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                            textAlign: TextAlign.center,
                            'Are you sure to Delete this ?!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cancel delete
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentWeekContent[rowIndex][colIndex] =
                                          const Text('');
                                    });
                                    notificationItemMap.removeWhere((item) =>
                                        item['row'] == rowIndex &&
                                        item['column'] == colIndex);
                                    mybox!.put('noti', notificationItemMap);
                                    Navigator.pop(
                                        context); // Close confirm dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Ok'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
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
                          setDialogState(() => _priority = value!);
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
                            rowIndex: rowIndex,
                            colIndex: colIndex,
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
                            "priority":
                                selectedCategory == 'Task' ? _priority : null,
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

  // Helper method to get day name from column index
  String _getDayName(int colIndex) {
    // This mapping should match the one in scheduleNotification
    switch (colIndex) {
      case 1:
        return 'السبت'; // Saturday
      case 2:
        return 'الأحد'; // Sunday
      case 3:
        return 'الاثنين'; // Monday
      case 4:
        return 'الثلاثاء'; // Tuesday
      case 5:
        return 'الأربعاء'; // Wednesday
      case 6:
        return 'الخميس'; // Thursday
      case 7:
        return 'الجمعة'; // Friday
      default:
        return 'يوم غير معروف';
    }
  }
}
