import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Weekly Report',
          style: commonTextStyle,
        ),
      ),
      body: notificationItemMap.isEmpty
          ? const Center(child: Text("No scudeled subjects yet"))
          : FutureBuilder(
              future: notificationItemMap.isNotEmpty
                  ? Future.value(notificationItemMap
                      .where((item) => item['week'] == currentWeekOffset)
                      .toList())
                  : Future.error('No data available'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No data available'));
                }
                // If data is available, display it
                List<Map<String, dynamic>> data =
                    snapshot.data as List<Map<String, dynamic>>;
                List<Map<String, dynamic>> studedSubjects =
                    data.where((item) => item['done'] == true).toList();
                List<Map<String, dynamic>> notStudedSubjects =
                    data.where((item) => item['done'] == false).toList();

                print("===============noti= $notificationItemMap");
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //text welcom
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'You\'re doing great, keep it up!',
                            style: commonTextStyle,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),
                        //anthor text
                        const Text(
                          textAlign: TextAlign.center,
                          'Here\'s a look at what you covered & not covered this week.',
                          style: midTextStyle,
                        ),

                        const SizedBox(
                          height: 16,
                        ),
                        //text subject studed
                        const Text(
                          'Subjects Studied',
                          style: commonTextStyle,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        //subject studed
                        studedSubjects.isEmpty
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text(
                                  'There is no studed element yet',
                                  style: midTextStyle,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: studedSubjects.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.all(6),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFe6e6e6)),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          bookimagepath,
                                          height: 50,
                                          width: 50,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${studedSubjects[index]['title']}",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            const Text('2h 30m')
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                        //text subject not studed
                        const Text(
                          'Subjects Not Studied',
                          style: commonTextStyle,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        notStudedSubjects.isEmpty
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text(
                                  'There is no notstuded element yet',
                                  style: midTextStyle,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notStudedSubjects.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.all(6),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xFFe6e6e6)),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          bookimagepath,
                                          height: 50,
                                          width: 50,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${notStudedSubjects[index]['title']}",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            const Text('2h 30m')
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(
                          height: 18,
                        ),
                        // const Text(
                        //     textAlign: TextAlign.center,
                        //     style: midTextStyle,
                        //     'Based on your availability, we have some suggestions for when you could study the subjects you missed this week.'),

                        // //suggested stydey times
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // const Text(
                        //   'Suggested Study Times',
                        //   style: commonTextStyle,
                        // ),
                        // const SizedBox(
                        //   height: 8,
                        // ),
                        // //stydey times
                        // Container(
                        //   margin: const EdgeInsets.all(6),
                        //   padding: const EdgeInsets.all(5),
                        //   decoration: BoxDecoration(
                        //       border:
                        //           Border.all(color: const Color(0xFFe6e6e6))),
                        //   child: Row(
                        //     children: [
                        //       Image.asset(
                        //         'images/calenderweeklyreport.png',
                        //         height: 50,
                        //         width: 60,
                        //       ),
                        //       const Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             'Today',
                        //             style: midTextStyle,
                        //           ),
                        //           Text('Biology'),
                        //           Text('4:00 PM - 5:00 PM'),
                        //         ],
                        //       )
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
