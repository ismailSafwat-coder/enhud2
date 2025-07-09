import 'package:enhud/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ExamNavigation extends StatelessWidget {
  final int currentPage;
  final int totalQuestions;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const ExamNavigation({
    super.key,
    required this.currentPage,
    required this.totalQuestions,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    bool isFirstPage = currentPage == 0;
    bool isLastQuestionPage = currentPage == totalQuestions - 1;
    bool isReviewPage = currentPage == totalQuestions;

    return Row(
      children: [
        if (!isFirstPage)
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              child: const Text("Previous"),
            ),
          ),
        if (!isFirstPage && !isReviewPage) const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isReviewPage ? AppColors.primary : AppColors.primary,
            ),
            onPressed: isReviewPage ? onSubmit : onNext,
            child: Text(
              isLastQuestionPage
                  ? "Review"
                  : (isReviewPage ? "Submit" : "Next"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
