import 'package:enhud/widget/exercise_question_card.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';

class ExercisesScreen extends StatefulWidget {
  final List<Question> questions;
  const ExercisesScreen({super.key, required this.questions});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Map<int, String?> _userAnswers;
  late Set<int> _revealedAnswers;

  @override
  void initState() {
    super.initState();
    _userAnswers = {};
    _revealedAnswers = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.questions.length} Questions"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          return ExerciseQuestionCard(
            question: widget.questions[index],
            questionIndex: index,
            totalQuestions: widget.questions.length,
            selectedAnswer: _userAnswers[index],
            isAnswerShown: _revealedAnswers.contains(index),
            onAnswerSelected: (choice) {
              if (!_revealedAnswers.contains(index)) {
                setState(() {
                  _userAnswers[index] = choice;
                });
              }
            },
            onShowAnswer: () {
              setState(() {
                _revealedAnswers.add(index);
              });
            },
          );
        },
      ),
    );
  }
}
