import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/app_colors.dart';

class PreSubmissionReviewPage extends StatefulWidget {
  final List<Question> questions;
  final List<String?> userAnswers;
  final List<bool> bookmarkedQuestions;
  final ValueChanged<int> onQuestionTapped;

  const PreSubmissionReviewPage({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.bookmarkedQuestions,
    required this.onQuestionTapped,
  });

  @override
  State<PreSubmissionReviewPage> createState() => _PreSubmissionReviewPageState();
}

class _PreSubmissionReviewPageState extends State<PreSubmissionReviewPage> {
  bool _showBookmarksOnly = false;

  @override
  Widget build(BuildContext context) {
    final List<int> displayIndices = [];
    if (_showBookmarksOnly) {
        for (int i = 0; i < widget.bookmarkedQuestions.length; i++) {
            if (widget.bookmarkedQuestions[i]) {
                displayIndices.add(i);
            }
        }
    } else {
        displayIndices.addAll(List.generate(widget.questions.length, (i) => i));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const Text("Questions of Exam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _showBookmarksOnly = false),
                            style: TextButton.styleFrom(
                                backgroundColor: !_showBookmarksOnly ? AppColors.primary : Colors.grey.shade200,
                                foregroundColor: !_showBookmarksOnly ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("All questions"),
                          ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _showBookmarksOnly = true),
                            icon: const Icon(Icons.bookmark, size: 16, color: Colors.orange),
                            label: const Text("Bookmarks"),
                             style: TextButton.styleFrom(
                                backgroundColor: _showBookmarksOnly ? AppColors.primary : Colors.grey.shade200,
                                foregroundColor: _showBookmarksOnly ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ),
                    ],
                  )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: displayIndices.isEmpty
            ? Center(child: Text(_showBookmarksOnly ? "No questions bookmarked." : "No questions available."))
            : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: displayIndices.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, i) {
                final int questionIndex = displayIndices[i];
                final isAnswered = widget.userAnswers[questionIndex] != null;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  title: Text("Question ${questionIndex + 1}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAnswered ? AppColors.correct.withOpacity(0.1) : AppColors.incorrect.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAnswered ? "Answered" : "Unanswered",
                          style: TextStyle(
                            color: isAnswered ? AppColors.correct : AppColors.incorrect,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                  onTap: () => widget.onQuestionTapped(questionIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}