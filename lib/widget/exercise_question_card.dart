import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/app_colors.dart';

class ExerciseQuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isAnswerShown;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onShowAnswer;

  const ExerciseQuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isAnswerShown,
    required this.onAnswerSelected,
    required this.onShowAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${questionIndex + 1} of $totalQuestions',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('1 point',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(question.text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...question.choices.map((choice) => _buildChoiceTile(choice)),
                const SizedBox(height: 20),
                if (!isAnswerShown)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAnswer == null
                          ? Colors.grey.shade300
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: selectedAnswer == null ? null : onShowAnswer,
                    child: const Text("Show Answer"),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChoiceTile(String choice) {
    bool isSelected = selectedAnswer == choice;
    Color? tileColor;
    IconData? trailingIcon;
    Color iconColor = AppColors.textDark;

    if (isAnswerShown) {
      bool isCorrect = question.correctAnswer == choice;
      if (isCorrect) {
        tileColor = AppColors.correct.withOpacity(0.15);
        trailingIcon = Icons.check_circle;
        iconColor = AppColors.correct;
      } else if (isSelected) {
        tileColor = AppColors.incorrect.withOpacity(0.15);
        trailingIcon = Icons.cancel;
        iconColor = AppColors.incorrect;
      }
    }

    return GestureDetector(
      onTap: () => onAnswerSelected(choice),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
              color: isSelected && !isAnswerShown
                  ? AppColors.primary
                  : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: choice,
              groupValue: selectedAnswer,
              onChanged:
                  isAnswerShown ? null : (value) => onAnswerSelected(value!),
              activeColor: AppColors.primary,
            ),
            Expanded(child: Text(choice)),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: iconColor),
            ]
          ],
        ),
      ),
    );
  }
}
