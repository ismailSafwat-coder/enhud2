import 'package:enhud/widget/answer_review_card.dart';
import 'package:flutter/material.dart';
import '../models/exam_result.dart';

class ReviewAnswersScreen extends StatelessWidget {
  final ExamResult result;
  const ReviewAnswersScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
        actions: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text("Points : ${result.points}/${result.totalQuestions}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: result.questions.length,
        itemBuilder: (context, index) {
          final question = result.questions[index];
          final userAnswer = result.userAnswers[index];
          final isCorrect = userAnswer == question.correctAnswer;

          return AnswerReviewCard(
            question: question,
            questionIndex: index,
            totalQuestions: result.totalQuestions,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
          );
        },
      ),
    );
  }
}
