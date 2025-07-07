import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/app_colors.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isBookmarked;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onBookmarkToggle;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isBookmarked,
    required this.onAnswerSelected,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${questionIndex + 1} of $totalQuestions',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.yellow),
                  onPressed: onBookmarkToggle,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 20),
                  ...question.choices.map((choice) {
                    bool isSelected = selectedAnswer == choice;
                    return GestureDetector(
                      onTap: () => onAnswerSelected(choice),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: choice,
                              groupValue: selectedAnswer,
                              onChanged: (value) => onAnswerSelected(value!),
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(choice, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}