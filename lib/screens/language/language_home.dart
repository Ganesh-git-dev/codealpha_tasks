import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/lesson.dart';
import '../../database/database_helper.dart';
import 'quiz_screen.dart';
import 'lesson_screen.dart';

class LanguageHomeScreen extends StatefulWidget {
  const LanguageHomeScreen({super.key});

  @override
  State<LanguageHomeScreen> createState() => _LanguageHomeScreenState();
}

class _LanguageHomeScreenState extends State<LanguageHomeScreen> {
  Language _selectedLanguage = Language.languages[0];
  String _selectedCategory = 'Greetings';
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  Map<String, double> _progress = {};
  FlutterTts? _tts;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts?.setLanguage(_selectedLanguage.code);
    await _tts?.setPitch(1.0);
    await _tts?.setSpeechRate(0.5);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _lessons = await DatabaseHelper.instance.getLessons(
      language: _selectedLanguage.name,
      category: _selectedCategory,
    );
    _progress = await DatabaseHelper.instance.getLanguageProgress(_selectedLanguage.name);
    setState(() => _isLoading = false);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts?.setLanguage(_selectedLanguage.code);
      await _tts?.speak(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS error: $e'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      }
    }
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: '${_selectedLanguage.flag} ${_selectedLanguage.name}',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        gradient: AppTheme.languageGradient,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddLessonScreen(
                language: _selectedLanguage.name,
                category: _selectedCategory,
              )));
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Column(
          children: [
            const SizedBox(height: 100),
            if (_progress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _progress.entries.map((e) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${e.key}: ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            Text('${e.value.round()}%', style: TextStyle(
                              color: e.value >= 70 ? AppTheme.success : (e.value >= 40 ? AppTheme.warning : AppTheme.error),
                              fontSize: 13, fontWeight: FontWeight.bold,
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Learn ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.languageGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage.name,
                        dropdownColor: AppTheme.cardBg,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        items: Language.languages.map((l) => DropdownMenuItem(
                          value: l.name,
                          child: Text('${l.flag} ${l.name}'),
                        )).toList(),
                        onChanged: (v) {
                          setState(() => _selectedLanguage = Language.languages.firstWhere((l) => l.name == v));
                          _tts?.setLanguage(_selectedLanguage.code);
                          _loadData();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: LessonCategory.vocabulary.map((cat) {
                  final isSelected = cat.name == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 16, color: isSelected ? Colors.white : AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(cat.name),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.gradientStart,
                      backgroundColor: AppTheme.cardBg,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary, fontSize: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                      onSelected: (v) {
                        setState(() => _selectedCategory = cat.name);
                        _loadData();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: 'Start Quiz',
                      icon: Icons.quiz,
                      gradient: AppTheme.languageGradient,
                      onTap: () async {
                        if (_lessons.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('No words in this category!'), backgroundColor: AppTheme.warning, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          );
                          return;
                        }
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
                          lessons: _lessons,
                          language: _selectedLanguage.name,
                          category: _selectedCategory,
                        )));
                        if (result == true) _loadData();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lessons.isEmpty
                      ? const EmptyState(icon: Icons.menu_book, title: 'No Words Yet', subtitle: 'Tap + to add words or switch categories')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _lessons.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _lessons.length) return const SizedBox(height: 100);
                            final lesson = _lessons[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: _LessonCard(
                                lesson: lesson,
                                onSpeak: () => _speak(lesson.word),
                                onDelete: () async {
                                  await DatabaseHelper.instance.deleteLesson(lesson.id!);
                                  _loadData();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onSpeak;
  final VoidCallback onDelete;

  const _LessonCard({required this.lesson, required this.onSpeak, required this.onDelete});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _showTranslation = !_showTranslation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onSpeak,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.language.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.volume_up, color: AppTheme.language, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showTranslation ? widget.lesson.translation : widget.lesson.word,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _showTranslation ? '${widget.lesson.word} (${widget.lesson.pronunciation})' : widget.lesson.pronunciation,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.language.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _showTranslation ? Icons.language : Icons.visibility,
                    color: AppTheme.language, size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
