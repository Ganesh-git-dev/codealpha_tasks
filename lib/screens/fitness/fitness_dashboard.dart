import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/workout.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class FitnessDashboard extends StatefulWidget {
  const FitnessDashboard({super.key});

  @override
  State<FitnessDashboard> createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard> {
  List<Workout> _workouts = [];
  bool _isLoading = true;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    final end = DateTime.now();
    final start = end.subtract(Duration(days: _selectedDays));
    final workouts = await DatabaseHelper.instance.getWorkoutsBetween(start, end);
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  double get _totalCalories => _workouts.fold(0, (s, w) => s + w.caloriesBurned);
  int get _totalMinutes => _workouts.fold(0, (s, w) => s + w.durationMinutes);
  int get _totalSteps => _workouts.fold(0, (s, w) => s + w.steps);
  int get _totalWorkouts => _workouts.length;

  Map<String, double> _dailyCalories() {
    final map = <String, double>{};
    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('MM/dd').format(date);
      map[key] = 0;
    }
    for (var w in _workouts) {
      final key = DateFormat('MM/dd').format(w.date);
      if (map.containsKey(key)) map[key] = map[key]! + w.caloriesBurned;
    }
    return map;
  }

  Map<String, int> _dailyMinutes() {
    final map = <String, int>{};
    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('MM/dd').format(date);
      map[key] = 0;
    }
    for (var w in _workouts) {
      final key = DateFormat('MM/dd').format(w.date);
      if (map.containsKey(key)) map[key] = map[key]! + w.durationMinutes;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Dashboard',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        gradient: AppTheme.fitnessGradient,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            color: AppTheme.cardBg,
            onSelected: (v) {
              setState(() => _selectedDays = v);
              _loadWorkouts();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 14, child: Text('Last 14 days', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 30, child: Text('Last 30 days', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: [AppTheme.surfaceDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadWorkouts,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: StatCard(title: 'Workouts', value: '$_totalWorkouts', icon: Icons.fitness_center, color: AppTheme.fitness)),
                          const SizedBox(width: 10),
                          Expanded(child: StatCard(title: 'Minutes', value: '$_totalMinutes', icon: Icons.timer, color: AppTheme.language)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: StatCard(title: 'Calories', value: '${_totalCalories.toStringAsFixed(0)} kcal', icon: Icons.local_fire_department, color: AppTheme.warning)),
                          const SizedBox(width: 10),
                          Expanded(child: StatCard(title: 'Steps', value: '$_totalSteps', icon: Icons.directions_walk, color: AppTheme.flashcard)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Daily Calories', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _dailyCalories().values.every((v) => v == 0)
                            ? const EmptyState(icon: Icons.bar_chart, title: 'No Data', subtitle: 'Start logging workouts to see charts')
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (_dailyCalories().values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                                  barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                                      '${rod.toY.toStringAsFixed(0)} kcal',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                                      final keys = _dailyCalories().keys.toList();
                                      if (v.toInt() >= 0 && v.toInt() < keys.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(keys[v.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                                        );
                                      }
                                      return const SizedBox();
                                    }, reservedSize: 22)),
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) {
                                      return Text('${v.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                                    })),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _dailyCalories().entries.toList().asMap().entries.map((e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [BarChartRodData(toY: e.value.value, color: AppTheme.warning, width: 14, borderRadius: BorderRadius.circular(4))],
                                  )).toList(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Text('Daily Minutes', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _dailyMinutes().values.every((v) => v == 0)
                            ? const EmptyState(icon: Icons.bar_chart, title: 'No Data', subtitle: 'Start logging workouts to see charts')
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (_dailyMinutes().values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                                  barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                                      '${rod.toY.toStringAsFixed(0)} min',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  )),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                                      final keys = _dailyMinutes().keys.toList();
                                      if (v.toInt() >= 0 && v.toInt() < keys.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(keys[v.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                                        );
                                      }
                                      return const SizedBox();
                                    }, reservedSize: 22)),
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) {
                                      return Text('${v.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                                    })),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _dailyMinutes().entries.toList().asMap().entries.map((e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: AppTheme.language, width: 14, borderRadius: BorderRadius.circular(4))],
                                  )).toList(),
                                ),
                              ),
                      ),
                      if (_workouts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Recent Activity', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        ...List.generate(_workouts.take(10).length, (i) {
                          final w = _workouts[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.fitness.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    ExerciseType.types.firstWhere((t) => t.name == w.exerciseType).icon,
                                    color: AppTheme.fitness, size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(w.exerciseType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      Text('${w.durationMinutes} min • ${w.caloriesBurned.toStringAsFixed(0)} kcal',
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd').format(w.date),
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
