import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../database/database_helper.dart';
import '../../widgets/common_widgets.dart';

class AddLessonScreen extends StatefulWidget {
  final String language;
  final String category;

  const AddLessonScreen({super.key, required this.language, required this.category});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordCtrl = TextEditingController();
  final _transCtrl = TextEditingController();
  final _pronCtrl = TextEditingController();

  @override
  void dispose() {
    _wordCtrl.dispose();
    _transCtrl.dispose();
    _pronCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DatabaseHelper.instance.insertLesson(Lesson(
      word: _wordCtrl.text.trim(),
      translation: _transCtrl.text.trim(),
      pronunciation: _pronCtrl.text.trim(),
      language: widget.language,
      category: widget.category,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Word added!'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Add Word',
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        gradient: AppTheme.languageGradient,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.language} • ${widget.category}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _wordCtrl,
                  decoration: const InputDecoration(labelText: 'Word', prefixIcon: Icon(Icons.text_fields, color: AppTheme.language)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transCtrl,
                  decoration: const InputDecoration(labelText: 'Translation', prefixIcon: Icon(Icons.translate, color: AppTheme.language)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pronCtrl,
                  decoration: const InputDecoration(labelText: 'Pronunciation', prefixIcon: Icon(Icons.record_voice_over, color: AppTheme.language)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                GradientButton(label: 'Save Word', icon: Icons.check_circle, gradient: AppTheme.languageGradient, onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
