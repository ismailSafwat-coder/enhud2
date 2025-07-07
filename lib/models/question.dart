class Question {
  final String text;
  final List<String> choices;
  final String correctAnswer;
  final String feedbackCorrect;
  final String feedbackIncorrect;

  Question({
    required this.text,
    required this.choices,
    required this.correctAnswer,
    this.feedbackCorrect = "Great job! Keep up the good work and keep striving to achieve your dream.",
    this.feedbackIncorrect = "Not quite right. Please review Unit 4, Lesson 1, and try again with the correct answer.",
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Basic validation
    if (json['question'] == null || json['choices'] == null || json['correct_answer'] == null) {
      throw const FormatException("Invalid question format from API.");
    }
    
    return Question(
      text: json['question'] as String,
      choices: List<String>.from(json['choices'].map((x) => x.toString())),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}