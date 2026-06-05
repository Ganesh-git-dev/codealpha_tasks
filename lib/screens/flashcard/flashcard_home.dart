import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_flashcard.dart';

class FlashcardHomeScreen extends StatefulWidget {
  const FlashcardHomeScreen({super.key});

  @override
  State<FlashcardHomeScreen> createState() => _FlashcardHomeScreenState();
}

class _FlashcardHomeScreenState extends State<FlashcardHomeScreen> with TickerProviderStateMixin {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    _cards = await DatabaseHelper.instance.getFlashcards();
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _isLoading = false;
    });
  }

  void _flip() {
    if (_flipCtrl.isCompleted) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _flipCtrl.reset();
      });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
        _flipCtrl.reset();
      });
    }
  }

  Future<void> _deleteCurrent() async {
    if (_cards.isEmpty) return;
    await DatabaseHelper.instance.deleteFlashcard(_cards[_currentIndex].id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Card deleted'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      _loadCards();
    }
  }

  Future<void> _editCurrent() async {
    if (_cards.isEmpty) return;
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddFlashcardScreen(editCard: _cards[_currentIndex])));
    if (result == true) _loadCards();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Flashcards',
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        gradient: AppTheme.flashcardGradient,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFlashcardScreen()));
            if (result == true) _loadCards();
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFlashcardScreen()));
          if (result == true) _loadCards();
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cards.isEmpty
                ? const EmptyState(icon: Icons.credit_card, title: 'No Flashcards', subtitle: 'Tap + to add your first card')
                : Column(
                    children: [
                      const SizedBox(height: 100),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_currentIndex + 1} of ${_cards.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.flashcard.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(_cards[_currentIndex].category, style: const TextStyle(color: AppTheme.flashcard, fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _flip,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: AspectRatio(
                                aspectRatio: 0.75,
                                child: AnimatedBuilder(
                                  animation: _flipAnim,
                                  builder: (context, child) {
                                    final isFront = _flipAnim.value < 0.5;
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(_flipAnim.value * 3.14159),
                                      child: isFront ? _buildCardFront() : Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(3.14159),
                                        child: _buildCardBack(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                label: 'Previous',
                                icon: Icons.arrow_back,
                                gradient: AppTheme.cardGradient,
                                onTap: _prev,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GradientButton(
                                label: 'Next',
                                icon: Icons.arrow_forward,
                                gradient: AppTheme.flashcardGradient,
                                onTap: _next,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gradientStart.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline, color: Colors.white70, size: 32),
          const SizedBox(height: 20),
          Text(
            _cards[_currentIndex].question,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text('Tap to reveal answer', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.flashcardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.flashcard.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb, color: Colors.white70, size: 32),
          const SizedBox(height: 20),
          Text(
            _cards[_currentIndex].answer,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: _editCurrent,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white70),
                onPressed: _deleteCurrent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

