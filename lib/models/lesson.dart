import 'package:flutter/material.dart';

class Lesson {
  final int? id;
  final String word;
  final String translation;
  final String pronunciation;
  final String language;
  final String category;

  Lesson({
    this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.language,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'word': word,
    'translation': translation,
    'pronunciation': pronunciation,
    'language': language,
    'category': category,
  };

  static Lesson fromMap(Map<String, dynamic> map) => Lesson(
    id: map['id'],
    word: map['word'],
    translation: map['translation'],
    pronunciation: map['pronunciation'],
    language: map['language'],
    category: map['category'],
  );
}

class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class Language {
  final String name;
  final String code;
  final String flag;

  const Language(this.name, this.code, this.flag);

  static const List<Language> languages = [
    Language('Spanish', 'es', '🇪🇸'),
    Language('French', 'fr', '🇫🇷'),
    Language('German', 'de', '🇩🇪'),
    Language('Italian', 'it', '🇮🇹'),
    Language('Japanese', 'ja', '🇯🇵'),
    Language('Korean', 'ko', '🇰🇷'),
  ];
}

class LessonCategory {
  final String name;
  final IconData icon;

  const LessonCategory(this.name, this.icon);

  static const List<LessonCategory> vocabulary = [
    LessonCategory('Greetings', Icons.waving_hand),
    LessonCategory('Numbers', Icons.numbers),
    LessonCategory('Colors', Icons.palette),
    LessonCategory('Food & Drinks', Icons.restaurant),
    LessonCategory('Family', Icons.family_restroom),
    LessonCategory('Travel', Icons.flight),
    LessonCategory('Weather', Icons.wb_sunny),
    LessonCategory('Animals', Icons.pets),
  ];
}

class QuizResult {
  final int? id;
  final String language;
  final String category;
  final int score;
  final int total;
  final DateTime date;

  QuizResult({
    this.id,
    required this.language,
    required this.category,
    required this.score,
    required this.total,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'language': language,
    'category': category,
    'score': score,
    'total': total,
    'date': date.toIso8601String(),
  };

  static QuizResult fromMap(Map<String, dynamic> map) => QuizResult(
    id: map['id'],
    language: map['language'],
    category: map['category'],
    score: map['score'],
    total: map['total'],
    date: DateTime.parse(map['date']),
  );
}
