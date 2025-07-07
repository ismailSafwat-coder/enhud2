import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class Todayschedule extends StatefulWidget {
  const Todayschedule({super.key});

  @override
  State<Todayschedule> createState() => _TodayscheduleState();
}

class _TodayscheduleState extends State<Todayschedule> {
  List<Map<String, dynamic>> noti = [];

  loaddata() async {
    var data = await mybox!.get('noti');

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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    return noti.isEmpty
        ? const Center(
            child: Text(
              'there is no schedule today',
              style: midTextStyle,
            ),
          )
        : SizedBox(
            height: deviceheight * 0.37,
            width: double.infinity,
            child: FutureBuilder(
              future: openHiveBox('noti'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Today Schedule :',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: noti.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //text
                                mycard(noti, index),
                                //listview card
                              ],
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          );
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
                        const Text(
                          ' 0hrs 30mins',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
