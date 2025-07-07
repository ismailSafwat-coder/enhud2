import 'question.dart';

class ExamResult {
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, String?> userAnswers;
  final List<Question> questions;
  final int timeConsumedInSeconds;

  ExamResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.userAnswers,
    required this.questions,
    required this.timeConsumedInSeconds,
  });

  double get percentage => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  int get incorrectAnswers => totalQuestions - correctAnswers;
  int get points => correctAnswers;
}