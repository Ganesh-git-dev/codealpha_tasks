class Flashcard {
  final int? id;
  final String question;
  final String answer;
  final String category;
  final DateTime createdAt;

  Flashcard({
    this.id,
    required this.question,
    required this.answer,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  static Flashcard fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'],
    question: map['question'],
    answer: map['answer'],
    category: map['category'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
