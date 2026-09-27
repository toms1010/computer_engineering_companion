class Subject {
  const Subject(
      {required this.id,
      required this.name,
      required this.category,
      required this.description,
      required this.icon,
      required this.completedLessons,
      required this.totalLessons});
  final int id;
  final String name, category, description, icon;
  final int completedLessons, totalLessons;
  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  Subject copyWith({int? completedLessons}) => Subject(
      id: id,
      name: name,
      category: category,
      description: description,
      icon: icon,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons);
  factory Subject.fromMap(Map<String, Object?> m) => Subject(
      id: m['id'] as int,
      name: m['name'] as String,
      category: m['category'] as String,
      description: m['description'] as String,
      icon: m['icon'] as String,
      completedLessons: m['completed_lessons'] as int? ?? 0,
      totalLessons: m['total_lessons'] as int? ?? 4);
}

class QuizQuestion {
  const QuizQuestion(
      {required this.id,
      required this.subjectId,
      required this.prompt,
      required this.options,
      required this.correctIndexes,
      required this.type,
      required this.explanation});
  final int id, subjectId;
  final String prompt, type, explanation;
  final List<String> options;
  final Set<int> correctIndexes;
}

class ActivityItem {
  const ActivityItem(this.description, this.createdAt);
  final String description;
  final DateTime createdAt;
}

class Note {
  const Note(
      {this.id,
      required this.title,
      required this.content,
      this.subjectId,
      required this.updatedAt});
  final int? id, subjectId;
  final String title, content;
  final DateTime updatedAt;
}
