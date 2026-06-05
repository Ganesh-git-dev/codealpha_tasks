import 'package:flutter/material.dart';

class Workout {
  final int? id;
  final String exerciseType;
  final int durationMinutes;
  final double caloriesBurned;
  final int steps;
  final DateTime date;

  Workout({
    this.id,
    required this.exerciseType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.steps,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'exerciseType': exerciseType,
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'steps': steps,
    'date': date.toIso8601String().split('T')[0],
  };

  static Workout fromMap(Map<String, dynamic> map) => Workout(
    id: map['id'],
    exerciseType: map['exerciseType'],
    durationMinutes: map['durationMinutes'],
    caloriesBurned: map['caloriesBurned'],
    steps: map['steps'],
    date: DateTime.parse(map['date']),
  );

  Workout copyWith({
    int? id,
    String? exerciseType,
    int? durationMinutes,
    double? caloriesBurned,
    int? steps,
    DateTime? date,
  }) => Workout(
    id: id ?? this.id,
    exerciseType: exerciseType ?? this.exerciseType,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    steps: steps ?? this.steps,
    date: date ?? this.date,
  );
}

class ExerciseType {
  final String name;
  final IconData icon;

  const ExerciseType(this.name, this.icon);

  static const List<ExerciseType> types = [
    ExerciseType('Running', Icons.directions_run),
    ExerciseType('Walking', Icons.directions_walk),
    ExerciseType('Cycling', Icons.directions_bike),
    ExerciseType('Swimming', Icons.pool),
    ExerciseType('Yoga', Icons.self_improvement),
    ExerciseType('Gym', Icons.fitness_center),
    ExerciseType('Dancing', Icons.music_note),
    ExerciseType('Other', Icons.sports_handball),
  ];
}
