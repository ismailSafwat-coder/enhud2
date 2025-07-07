import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhud/pages/homescreen.dart';
import 'package:enhud/widget/custombuttom1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountinfoPage extends StatefulWidget {
  const AccountinfoPage({super.key});

  @override
  State<AccountinfoPage> createState() => _AccountinfoPageState();
}

class _AccountinfoPageState extends State<AccountinfoPage> {
  bool userstoreinfirestore = true;
  TextEditingController acadimicyear = TextEditingController();
  TextEditingController gender = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if Firestore data exists
          bool hasData = snapshot.hasData && snapshot.data!.exists;
          if (hasData == false) {
            userstoreinfirestore = false;
          }
          final Map<String, dynamic> userData = hasData
              ? snapshot.data!.data() as Map<String, dynamic>
              : {
                  'name': currentUser.displayName ?? 'No name',
                  'email': currentUser.email ?? 'No email',
                  'photoURL': currentUser.photoURL,
                  'academicYear': 'Unknown',
                  'gender': 'Unknown',
                };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header container
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF5f8cf8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userData['photoURL'] != null
                          ? NetworkImage(userData['photoURL'])
                          : const AssetImage('images/accountimage.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hi, ${userData['name'].toString().trimLeft()}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Divider(thickness: 2),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel('Full name'),
                      buildReadOnlyField(userData['name'], false, null),
                      buildLabel('E-mail'),
                      buildReadOnlyField(userData['email'], false, null),
                      buildLabel('Academic Year'),
                      buildReadOnlyField(userData['academicYear'],
                          userstoreinfirestore, acadimicyear),
                      buildLabel('Gender'),
                      buildReadOnlyField(
                          userData['gender'], userstoreinfirestore, gender),
                      // if (!userstoreinfirestore)
                      //   Center(
                      //       child: Custombuttom1(
                      //           onPressed: () {
                      //             if (acadimicyear) {}
                      //           },
                      //           text: "Update")),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: bottmbar(context),
    );
  }

  Widget buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
        ),
      );

  Widget buildReadOnlyField(
          String value, bool cahcahnge, TextEditingController? controlle) =>
      SizedBox(
        width: double.infinity,
        child: TextFormField(
          controller: controlle,
          readOnly: !cahcahnge,
          decoration: InputDecoration(
            hintText: value,
            hintStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFededed)),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );

  Container bottmbar(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFFd9d9d9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navIcon('images/Home.svg', 0),
          navIcon('images/Timetable.svg', 1),
          navIcon('images/Add.svg', 2),
          navIcon('images/Exam.svg', 3),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset('images/Settings.svg'),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF5f8cf8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget navIcon(String asset, int index) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen(homeindex: index)),
          (route) => false,
        );
      },
      child: SvgPicture.asset(asset),
    );
  }
}
