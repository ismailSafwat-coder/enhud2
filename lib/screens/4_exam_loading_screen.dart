import 'dart:io';
import 'package:flutter/material.dart';
import '../api/exam_api.dart';
import '../models/question.dart';
import '5_exam_taking_screen.dart';
import '8_exercises_screen.dart';

class ExamLoadingScreen extends StatefulWidget {
  final File file;
  final bool isExamMode;

  const ExamLoadingScreen(
      {super.key, required this.file, required this.isExamMode});

  @override
  State<ExamLoadingScreen> createState() => _ExamLoadingScreenState();
}

class _ExamLoadingScreenState extends State<ExamLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showInstructionsAndLoad());
  }

  Future<void> _showInstructionsAndLoad() async {
    final bool? start = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const InstructionsDialog(),
    );

    if (start == true) {
      _loadContent();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _loadContent() async {
    try {
      final questions = await ExamApi.generateExamFromFile(widget.file);
      if (!mounted) return;

      if (widget.isExamMode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ExamTakingScreen(questions: questions)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ExercisesScreen(questions: questions)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Generating content from file..."),
          ],
        ),
      ),
    );
  }
}

class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Instructions for this Exam",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text("• Number of questions: 10"),
                SizedBox(height: 8),
                Text("• Has a time limit of: 00:10:00"),
                SizedBox(height: 8),
                Text("• Attempts allowed: Unlimited"),
                SizedBox(height: 8),
                Text("• Has a passmark of: 60%"),
                SizedBox(height: 8),
                Text("• Must be finished in one sitting."),
                SizedBox(height: 8),
                Text("• You can go back and change your answers."),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Let's go"),
          ),
        ],
      ),
    );
  }
}
