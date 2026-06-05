import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'fitness/fitness_home.dart';
import 'language/language_home.dart';
import 'flashcard/flashcard_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.surfaceDark, AppTheme.primaryMid, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gradientStart.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SkillHub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Learn • Train • Excel',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.fitness_center,
                          title: 'Fitness Tracker',
                          subtitle: 'Log workouts, track calories, view progress with charts',
                          gradient: AppTheme.fitnessGradient,
                          color: AppTheme.fitness,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FitnessHomeScreen())),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.translate,
                          title: 'Language Learning',
                          subtitle: 'Learn words, take quizzes, track your progress',
                          gradient: AppTheme.languageGradient,
                          color: AppTheme.language,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageHomeScreen())),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.credit_card,
                          title: 'Flashcard Quiz',
                          subtitle: 'Create cards, flip to reveal answers, test yourself',
                          gradient: AppTheme.flashcardGradient,
                          color: AppTheme.flashcard,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardHomeScreen())),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.storage, color: AppTheme.textSecondary, size: 20),
                              const SizedBox(width: 10),
                              const Text('All data stored locally using SQLite', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
