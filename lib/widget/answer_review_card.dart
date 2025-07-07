import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/app_colors.dart';

class AnswerReviewCard extends StatelessWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String? userAnswer;
  final bool isCorrect;

  const AnswerReviewCard({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.userAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${questionIndex + 1} of $totalQuestions', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(isCorrect ? '1 point' : '0 point', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...question.choices.map((choice) => _buildChoiceTile(choice)).toList(),
                const SizedBox(height: 16),
                _buildFeedbackBox(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChoiceTile(String choice) {
    bool isSelectedUser = userAnswer == choice;
    bool isCorrectAnswer = question.correctAnswer == choice;
    
    Color tileColor = Colors.transparent;
    IconData? trailingIcon;
    Color iconColor = AppColors.textDark;

    if (isCorrectAnswer) {
      tileColor = AppColors.correct.withOpacity(0.15);
      trailingIcon = Icons.check_circle;
      iconColor = AppColors.correct;
    } else if (isSelectedUser && !isCorrectAnswer) {
      tileColor = AppColors.incorrect.withOpacity(0.15);
      trailingIcon = Icons.cancel;
      iconColor = AppColors.incorrect;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tileColor == Colors.transparent ? Colors.grey.shade300 : tileColor.withOpacity(0.5))
      ),
      child: Row(
        children: [
          Expanded(child: Text(choice, style: const TextStyle(fontSize: 16))),
          if (trailingIcon != null) ...[
             const SizedBox(width: 8),
             Icon(trailingIcon, color: iconColor)
          ]
        ],
      ),
    );
  }

  Widget _buildFeedbackBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isCorrect ? AppColors.correct : AppColors.incorrect, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(isCorrect ? question.feedbackCorrect : question.feedbackIncorrect, style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
        ],
      ),
    );
  }
}