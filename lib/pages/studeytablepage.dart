// ... (keep your existing imports)
import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:enhud/utils/app_colors.dart';

import 'package:flutter/material.dart';

const commonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

class Studeytablepage extends StatefulWidget {
  const Studeytablepage({super.key});

  @override
  State<Studeytablepage> createState() => _StudeytablepageState();
}

class _StudeytablepageState extends State<Studeytablepage> {
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late double height;
  late double width;
  String? priority;

  // Track current week offset
  // Store content for all weeks

  final List<String> categories = [
    "Material",
    "Task",
    "StudyDialog",
    "Exam",
    "Activity",
    "sleep",
    "freetime",
    "Another Class"
  ];

  void _initializeWeeksContent() {
    if (allWeeksContent.isEmpty) {
      allWeeksContent.add(_createNewWeekContent());
    }
  }

  List<List<Widget>> _createNewWeekContent() {
    return List.generate(
      timeSlots.length,
      (_) => List.filled(8, const Text('')),
    );
  }

  List<List<Widget>> get _currentWeekContent {
    while (currentWeekOffset >= allWeeksContent.length) {
      allWeeksContent.add(_createNewWeekContent());
    }
    return allWeeksContent[currentWeekOffset];
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Task':
      case 'StudyDialog':
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

  String _extractFirstTime(String timeSlot) {
    return timeSlot.split(' - ').first.trim();
  }

  @override
  void initState() {
    super.initState();

    _initializeWeeksContent();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.sizeOf(context).height;
    width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          decoration: BoxDecoration(
              // border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(20)),
          height: height * 0.1,
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(),
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey,
                    ),
                    height: height * 0.02,
                    width: height * 0.02,
                  ),
                  const Text(
                    ' Empty',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.yellow,
                    ),
                    height: height * 0.02,
                    width: height * 0.02,
                  ),
                  const Text(
                    ' Activity',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.orange,
                    ),
                    height: height * 0.02,
                    width: height * 0.02,
                  ),
                  const Text(
                    ' StudyDialog / Task',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.red,
                    ),
                    height: height * 0.02,
                    width: height * 0.02,
                  ),
                  const Text(
                    ' Exam',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.primary,
                    ),
                    height: height * 0.02,
                    width: height * 0.02,
                  ),
                  const Text(
                    ' Material',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ],
          )),
      appBar: AppBar(
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
        title: Text(_getWeekTitle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 2),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(children: [
      _buildTableCell('Day / Time', isHeader: true),
      _buildTableCell('Sat', isHeader: true, addpadding: true),
      _buildTableCell('Sun', isHeader: true, addpadding: true),
      _buildTableCell('Mon', isHeader: true, addpadding: true),
      _buildTableCell('Tue', isHeader: true, addpadding: true),
      _buildTableCell('Wed', isHeader: true, addpadding: true),
      _buildTableCell('Thu', isHeader: true, addpadding: true),
      _buildTableCell('Fri', isHeader: true, addpadding: true),
    ]);
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
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCellWithGesture(int rowIndex, int colIndex) {
    return GestureDetector(
      onTap: () {
        // _showAddItemDialog(rowIndex, colIndex);
      },
      child: Container(
        color: const Color(0xffE4E4E4),
        child: Center(
          child: _currentWeekContent.isNotEmpty &&
                  rowIndex < _currentWeekContent.length &&
                  colIndex < _currentWeekContent[rowIndex].length
              ? _currentWeekContent[rowIndex][colIndex]
              : const Text(''),
        ),
      ),
    );
  }
}
