import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/exam_result.dart';
import '../utils/app_colors.dart';
import '7_review_answers_screen.dart';

class ResultsScreen extends StatelessWidget {
  final ExamResult result;
  const ResultsScreen({super.key, required this.result});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;
    return '$minutes Min ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    bool passed = result.percentage >= 60;

    return Scaffold(
      appBar: AppBar(title: const Text("Exam Result")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultRow("Points :",
                            "${result.points}/${result.totalQuestions}"),
                        const SizedBox(height: 8),
                        _buildResultRow("Percentage :",
                            "${result.percentage.toStringAsFixed(0)}%"),
                        const SizedBox(height: 8),
                        _buildResultRow("Time Consumed :",
                            _formatDuration(result.timeConsumedInSeconds)),
                      ],
                    ),
                    CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 10.0,
                      percent: result.percentage / 100,
                      center: Text("${result.percentage.toStringAsFixed(0)}%",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      progressColor: AppColors.correct,
                      backgroundColor: AppColors.correct.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnswerStat(
                        "Correct", result.correctAnswers, AppColors.correct),
                    _buildAnswerStat("Incorrect", result.incorrectAnswers,
                        AppColors.incorrect),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                          width: 5,
                          height: 40,
                          decoration: BoxDecoration(
                              color: passed
                                  ? AppColors.correct
                                  : AppColors.incorrect,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              passed
                                  ? "Congratulations! You have passed the exam."
                                  : "Sorry, you did not pass. Better luck next time!",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600))),
                    ],
                  ),
                )),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReviewAnswersScreen(result: result)));
              },
              child: const Text(
                "View Answers",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value) {
    return Row(children: [
      Text(title,
          style: const TextStyle(fontSize: 16, color: AppColors.textLight)),
      const SizedBox(width: 8),
      Text(value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark)),
    ]);
  }

  Widget _buildAnswerStat(String title, int count, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Text(count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)))
      ],
    );
  }
}
