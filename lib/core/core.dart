import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> notificationItemMap = [];
String userid = FirebaseAuth.instance.currentUser!.uid;
List<List<List<Widget>>> allWeeksContent = [];

List<String> timeSlots = [
  '08:00 am - 09:00 am',
  '09:00 am - 10:00 am',
  '10:00 am - 11:00 am',
];

String week = 'week';

String row = 'row';
String column = 'column';
String title = 'title';
String description = 'description';
String category = 'category';

String bookimagepath = 'images/bookimage.jpg';
