import 'dart:async';
import 'package:enhud/utils/app_colors.dart';
import 'package:enhud/widget/exam_header.dart';
import 'package:enhud/widget/exam_navigation.dart';
import 'package:enhud/widget/pre_submission_review_page.dart';
import 'package:enhud/widget/question_card.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/exam_result.dart';
import '6_results_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final List<Question> questions;
  const ExamTakingScreen({super.key, required this.questions});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _timeRemainingInSeconds = 600; // 10 minutes
  late List<String?> _userAnswers;
  late List<bool> _bookmarkedQuestions;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _userAnswers = List<String?>.filled(widget.questions.length, null);
    _bookmarkedQuestions = List<bool>.filled(widget.questions.length, false);
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingInSeconds > 0) {
        if (mounted) setState(() => _timeRemainingInSeconds--);
      } else {
        _submitExam();
        timer.cancel();
      }
    });
  }

  void _submitExam() {
    _timer?.cancel();
    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_userAnswers[i] == widget.questions[i].correctAnswer) {
        correctCount++;
      }
    }

    final result = ExamResult(
      totalQuestions: widget.questions.length,
      correctAnswers: correctCount,
      userAnswers: Map.fromEntries(_userAnswers.asMap().entries),
      questions: widget.questions,
      timeConsumedInSeconds: 600 - _timeRemainingInSeconds,
    );

    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ResultsScreen(result: result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              ExamHeader(
                timeRemaining: _formatTime(_timeRemainingInSeconds),
                progress: (_currentPage) / (widget.questions.length),
                isReviewPage: _currentPage == widget.questions.length,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    ...List.generate(
                      widget.questions.length,
                      (index) => QuestionCard(
                        question: widget.questions[index],
                        questionIndex: index,
                        totalQuestions: widget.questions.length,
                        selectedAnswer: _userAnswers[index],
                        isBookmarked: _bookmarkedQuestions[index],
                        onAnswerSelected: (choice) =>
                            setState(() => _userAnswers[index] = choice),
                        onBookmarkToggle: () => setState(() =>
                            _bookmarkedQuestions[index] =
                                !_bookmarkedQuestions[index]),
                      ),
                    ),
                    PreSubmissionReviewPage(
                      questions: widget.questions,
                      userAnswers: _userAnswers,
                      bookmarkedQuestions: _bookmarkedQuestions,
                      onQuestionTapped: (index) =>
                          _pageController.jumpToPage(index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.questions.length + 1,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ExamNavigation(
                currentPage: _currentPage,
                totalQuestions: widget.questions.length,
                onNext: () {
                  if (_currentPage < widget.questions.length) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                onPrevious: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                onSubmit: _submitExam,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
