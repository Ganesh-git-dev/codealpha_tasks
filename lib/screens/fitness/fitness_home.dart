import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'add_workout.dart';
import 'fitness_dashboard.dart';

class FitnessHomeScreen extends StatelessWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.fitnessGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fitness Tracker', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        Text('Track your progress', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildMenuCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Log Workout',
                  subtitle: 'Record your daily exercise',
                  color: AppTheme.fitness,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWorkoutScreen())),
                ),
                const SizedBox(height: 14),
                _buildMenuCard(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  subtitle: 'View progress & charts',
                  color: AppTheme.language,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FitnessDashboard())),
                ),
                const SizedBox(height: 14),
                _buildMenuCard(
                  context,
                  icon: Icons.sync,
                  title: 'Connect Google Fit',
                  subtitle: 'Sync workout data automatically',
                  color: const Color(0xFF4285F4),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Google Fit integration coming soon!'),
                          ],
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.fitnessGradient.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.fitness.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: AppTheme.fitness, size: 36),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stay Active!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            Text('Log your workouts daily to track progress', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
