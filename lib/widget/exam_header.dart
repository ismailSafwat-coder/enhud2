import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ExamHeader extends StatelessWidget {
  final String timeRemaining;
  final double progress;
  final bool isReviewPage;

  const ExamHeader({
    super.key,
    required this.timeRemaining,
    required this.progress,
    this.isReviewPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.timer_outlined, color: AppColors.textLight, size: 20),
                SizedBox(width: 8),
                Text('Time left', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              ],
            ),
            Text(
              timeRemaining,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(isReviewPage ? AppColors.incorrect : AppColors.accent),
          ),
        ),
      ],
    );
  }
}