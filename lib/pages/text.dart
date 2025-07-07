import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:enhud/core/core.dart';

class TestPageTable extends StatefulWidget {
  const TestPageTable({super.key});

  @override
  State<TestPageTable> createState() => _TestPageTableState();
}

class _TestPageTableState extends State<TestPageTable> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double height;
  late double width;
  String? _priority;
  TimeOfDay? startTime;
  int id = DateTime.now().millisecondsSinceEpoch % 1000000000;
  int currentWeekOffset = 0;
  List<List<List<Widget>>> allWeeksContent = [];
  List<String> timeSlots = [
    '08:00 am - 09:00 am',
    '09:00 am - 10:00 am',
    '10:00 am - 11:00 am',
  ];

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
    if (allWeeksContent.isEmpty) {
      allWeeksContent.add(_createNewWeekContent());
    }
  }

  List<List<Widget>> _createNewWeekContent() {
    return List.generate(
        timeSlots.length, (_) => List.filled(8, const Text('')));
  }

  List<List<Widget>> get _currentWeekContent {
    while (currentWeekOffset >= allWeeksContent.length) {
      allWeeksContent.add(_createNewWeekContent());
    }
    return allWeeksContent[currentWeekOffset];
  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekOffset--;
      if (currentWeekOffset < 0) {
        currentWeekOffset = 0;
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
      for (var weekContent in allWeeksContent) {
        weekContent.add(List.filled(8, const Text('')));
      }
    });
    _saveTimeSlots();
  }

  Future<void> pickTimeAndScheduleNotification(
      String timeSlot, BuildContext context, String title, String body) async {
    String rawTime = _extractFirstTime(timeSlot);
    TimeOfDay? parsedTime = parseTime(rawTime);

    if (parsedTime != null) {
      Notifications().scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch % 1000000000,
        title: title,
        body: body,
        hour: parsedTime.hour,
        minute: parsedTime.minute,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification scheduled for $rawTime')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse time')),
      );
    }
  }

  Future<void> storeEoHive(Map<String, dynamic> newData) async {
    try {
      if (!mybox!.isOpen) {
        throw Exception('Hive box is not open');
      }

      List<Map<String, dynamic>> currentList =
          mybox!.containsKey('noti') ? List.from(mybox!.get('noti')) : [];

      currentList.add(newData);
      await mybox!.put('noti', currentList);
    } catch (e) {
      print('Error storing data: $e');
      rethrow;
    }
  }

  Future<void> retriveDateFromhive() async {
    try {
      if (!mybox!.isOpen) return;
      if (!mybox!.containsKey('noti')) return;

      late List<Map<String, dynamic>> noti;
      var data = mybox!.get('noti');
      if (data is List) {
        noti = List<Map<String, dynamic>>.from(data.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            return {};
          }
        }));
      } else {
        noti = [];
      }

      final double height = MediaQuery.of(context).size.height;

      for (final data in noti) {
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

        while (row >= allWeeksContent[week].length) {
          allWeeksContent[week].add(List.filled(8, const Text('')));
        }

        if (col >= allWeeksContent[week][row].length) continue;

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
      setState(() {});
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
      for (var weekContent in allWeeksContent) {
        while (weekContent.length < timeSlots.length) {
          weekContent.add(List.filled(8, const Text('')));
        }
      }
    });
  }

  String _extractFirstTime(String timeSlot) {
    return timeSlot.split(' - ').first.trim();
  }

  TimeOfDay? parseTime(String timeString) {
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
    return null;
  }

  DateTime _calculateDateFromCell(int rowIndex, int colIndex) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday));

    return startOfWeek.add(Duration(
      days: colIndex - 1 + (7 * currentWeekOffset),
    ));
  }

  int _getColumnIndex(DateTime date) {
    return date.weekday % 7; // Sunday=0, Monday=1, ..., Saturday=6
  }

  int _getWeekOffset(DateTime date) {
    final now = DateTime.now();
    final startOfCurrentWeek = now.subtract(Duration(days: now.weekday));
    final startOfTargetWeek = date.subtract(Duration(days: date.weekday));

    return startOfTargetWeek.difference(startOfCurrentWeek).inDays ~/ 7;
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
    final cellDate = _calculateDateFromCell(rowIndex, colIndex);
    final isToday = cellDate.year == DateTime.now().year &&
        cellDate.month == DateTime.now().month &&
        cellDate.day == DateTime.now().day;

    return GestureDetector(
      onTap: () {
        _showAddItemDialog(rowIndex, colIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          border: isToday ? Border.all(color: Colors.red, width: 2) : null,
          color: const Color(0xffE4E4E4),
        ),
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
    DateTime selectedDate = _calculateDateFromCell(rowIndex, colIndex);
    TimeOfDay selectedTime = TimeOfDay.now();

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

                  // Date Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Text(DateFormat('EEE, MMM d').format(selectedDate)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Time Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 10),
                        Text(selectedTime.format(context)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setDialogState(() => selectedTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Category Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
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
                      if (taskController.text.isEmpty &&
                          selectedCategory != 'sleep' &&
                          selectedCategory != 'freetime') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a title')),
                        );
                        return;
                      }

                      final newColIndex = _getColumnIndex(selectedDate);
                      final newWeekOffset = _getWeekOffset(selectedDate);
                      final newRowIndex =
                          rowIndex; // Or calculate based on time

                      // Schedule notification
                      pickTimeAndScheduleNotification(
                        timeSlots[rowIndex],
                        context,
                        taskController.text,
                        Descriptioncontroller.text,
                      );

                      // Prepare data to store
                      Map<String, dynamic> notificationInfotoStore = {
                        'id': id,
                        "week": newWeekOffset,
                        "row": newRowIndex,
                        'column': newColIndex,
                        "title": taskController.text.trim(),
                        "description": Descriptioncontroller.text.trim(),
                        "category": selectedCategory,
                        "done": false,
                        "date": selectedDate.toString(),
                        "time": selectedTime.format(context),
                      };

                      // Store in Hive
                      storeEoHive(notificationInfotoStore);

                      // Update UI
                      setState(() {
                        // Ensure we have enough weeks
                        while (newWeekOffset >= allWeeksContent.length) {
                          allWeeksContent.add(_createNewWeekContent());
                        }

                        // Ensure we have enough rows
                        while (newRowIndex >=
                            allWeeksContent[newWeekOffset].length) {
                          allWeeksContent[newWeekOffset]
                              .add(List.filled(8, const Text('')));
                        }

                        // Create the widget to display
                        allWeeksContent[newWeekOffset][newRowIndex]
                            [newColIndex] = Container(
                          padding: const EdgeInsets.all(0),
                          height: height * 0.13,
                          width: double.infinity,
                          color: _getCategoryColor(selectedCategory ?? ''),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
