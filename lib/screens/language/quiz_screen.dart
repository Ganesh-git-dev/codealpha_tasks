import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../database/database_helper.dart';
import '../../widgets/common_widgets.dart';

class QuizScreen extends StatefulWidget {
  final List<Lesson> lessons;
  final String language;
  final String category;

  const QuizScreen({super.key, required this.lessons, required this.language, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late List<_QItem> _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool _showResult = false;
  int? _selectedAnswer;
  bool _answered = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
    _generateQuestions();
  }

  void _generateQuestions() {
    final rand = Random();
    _questions = widget.lessons.map((l) {
      final wrongOptions = widget.lessons
          .where((w) => w.translation != l.translation)
          .toList()
        ..shuffle(rand);
      final options = [l.translation, ...wrongOptions.take(3).map((w) => w.translation)].toList()..shuffle(rand);
      return _QItem(question: 'What does "${l.word}" mean?', correctAnswer: l.translation, options: options);
    }).toList()
      ..shuffle(rand);
  }

  void _answer(String answer) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedAnswer = _questions[_currentIndex].options.indexOf(answer);
      if (answer == _questions[_currentIndex].correctAnswer) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _animCtrl.reset();
      _animCtrl.forward();
    } else {
      DatabaseHelper.instance.insertQuizResult(QuizResult(
        language: widget.language,
        category: widget.category,
        score: _score,
        total: _questions.length,
      ));
      setState(() => _showResult = true);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult();

    final q = _questions[_currentIndex];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Quiz (${_currentIndex + 1}/${_questions.length})',
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        gradient: AppTheme.languageGradient,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.language.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Score: $_score', style: const TextStyle(color: AppTheme.language, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(q.options.length, (i) {
                    final option = q.options[i];
                    Color? bgColor;
                    Color? txtColor = Colors.white;
                    if (_answered) {
                      if (option == q.correctAnswer) {
                        bgColor = AppTheme.success.withValues(alpha: 0.2);
                        txtColor = AppTheme.success;
                      } else if (i == _selectedAnswer) {
                        bgColor = AppTheme.error.withValues(alpha: 0.2);
                        txtColor = AppTheme.error;
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _answer(option),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: bgColor ?? AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _answered && option == q.correctAnswer
                                    ? AppTheme.success
                                    : (i == _selectedAnswer ? AppTheme.error : AppTheme.cardBg),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: bgColor?.withValues(alpha: 0.3) ?? AppTheme.primaryDark,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(child: Text(String.fromCharCode(65 + i), style: TextStyle(color: txtColor, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Text(option, style: TextStyle(color: txtColor, fontSize: 16))),
                                if (_answered && option == q.correctAnswer)
                                  const Icon(Icons.check_circle, color: AppTheme.success),
                                if (_answered && i == _selectedAnswer && option != q.correctAnswer)
                                  const Icon(Icons.cancel, color: AppTheme.error),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  if (_answered)
                    GradientButton(
                      label: _currentIndex < _questions.length - 1 ? 'Next Question' : 'See Results',
                      icon: Icons.arrow_forward,
                      gradient: AppTheme.languageGradient,
                      onTap: _next,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_score / _questions.length * 100).round();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Quiz Complete!',
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        gradient: AppTheme.languageGradient,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    gradient: AppTheme.languageGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  pct >= 80 ? 'Excellent!' : pct >= 60 ? 'Good Job!' : 'Keep Practicing!',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$_score / ${_questions.length} correct', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Try Again',
                  icon: Icons.refresh,
                  gradient: AppTheme.languageGradient,
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                      _score = 0;
                      _showResult = false;
                      _selectedAnswer = null;
                      _answered = false;
                    });
                    _generateQuestions();
                    _animCtrl.reset();
                    _animCtrl.forward();
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Lessons', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QItem {
  final String question;
  final String correctAnswer;
  final List<String> options;

  _QItem({required this.question, required this.correctAnswer, required this.options});
}
