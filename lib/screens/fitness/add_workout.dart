import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Running';
  bool _isLoading = false;

  @override
  void dispose() {
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.gradientStart,
            onPrimary: Colors.white,
            surface: AppTheme.cardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.insertWorkout(Workout(
      exerciseType: _selectedType,
      durationMinutes: int.parse(_durationCtrl.text),
      caloriesBurned: double.parse(_caloriesCtrl.text),
      steps: int.parse(_stepsCtrl.text.isNotEmpty ? _stepsCtrl.text : '0'),
      date: _selectedDate,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout logged!'),
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
        title: 'Log Workout',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
                const Text('Exercise Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  dropdownColor: AppTheme.cardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      ExerciseType.types.firstWhere((t) => t.name == _selectedType).icon,
                      color: AppTheme.fitness,
                    ),
                  ),
                  items: ExerciseType.types.map((t) => DropdownMenuItem(
                    value: t.name,
                    child: Row(
                      children: [
                        Icon(t.icon, color: AppTheme.fitness, size: 20),
                        const SizedBox(width: 12),
                        Text(t.name),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                  validator: (v) => v == null ? 'Select type' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          prefixIcon: Icon(Icons.timer, color: AppTheme.fitness),
                          hintText: 'min',
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          prefixIcon: Icon(Icons.local_fire_department, color: AppTheme.warning),
                          hintText: 'kcal',
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stepsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Steps (optional)',
                    prefixIcon: Icon(Icons.directions_walk, color: AppTheme.fitness),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today, color: AppTheme.fitness),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: _isLoading ? 'Saving...' : 'Save Workout',
                  icon: Icons.check_circle,
                  gradient: AppTheme.fitnessGradient,
                  onTap: _isLoading ? () {} : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
