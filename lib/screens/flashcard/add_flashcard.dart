import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddFlashcardScreen extends StatefulWidget {
  final Flashcard? editCard;

  const AddFlashcardScreen({super.key, this.editCard});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.editCard != null) {
      _isEditing = true;
      _questionCtrl.text = widget.editCard!.question;
      _answerCtrl.text = widget.editCard!.answer;
      _categoryCtrl.text = widget.editCard!.category;
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final card = Flashcard(
      id: widget.editCard?.id,
      question: _questionCtrl.text.trim(),
      answer: _answerCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      createdAt: widget.editCard?.createdAt,
    );
    if (_isEditing) {
      await DatabaseHelper.instance.updateFlashcard(card);
    } else {
      await DatabaseHelper.instance.insertFlashcard(card);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Card updated!' : 'Card added!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: _isEditing ? 'Edit Card' : 'Add Card',
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        gradient: AppTheme.flashcardGradient,
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
                TextFormField(
                  controller: _questionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.help_outline, color: AppTheme.flashcard),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _answerCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.lightbulb_outline, color: AppTheme.flashcard),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined, color: AppTheme.flashcard),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: _isEditing ? 'Update Card' : 'Save Card',
                  icon: Icons.check_circle,
                  gradient: AppTheme.flashcardGradient,
                  onTap: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
