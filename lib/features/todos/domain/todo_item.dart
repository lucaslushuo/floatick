class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.completedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? archivedAt;

  bool get isCompleted => completedAt != null;
  bool get isArchived => archivedAt != null;

  TodoItem withTitle(String value) {
    return TodoItem(
      id: id,
      title: value,
      createdAt: createdAt,
      completedAt: completedAt,
      archivedAt: archivedAt,
    );
  }

  TodoItem withCompletedAt(DateTime? value) {
    return TodoItem(
      id: id,
      title: title,
      createdAt: createdAt,
      completedAt: value,
      archivedAt: archivedAt,
    );
  }

  TodoItem withArchivedAt(DateTime? value) {
    return TodoItem(
      id: id,
      title: title,
      createdAt: createdAt,
      completedAt: completedAt,
      archivedAt: value,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      createdAt: _requiredDate(json, 'createdAt'),
      completedAt: _optionalDate(json, 'completedAt'),
      archivedAt: _optionalDate(json, 'archivedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toUtc().toIso8601String(),
      if (completedAt != null)
        'completedAt': completedAt!.toUtc().toIso8601String(),
      if (archivedAt != null)
        'archivedAt': archivedAt!.toUtc().toIso8601String(),
    };
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Todo field "$key" must be a non-empty string.');
    }
    return value;
  }

  static DateTime _requiredDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Todo field "$key" must be an ISO-8601 string.');
    }
    return DateTime.parse(value);
  }

  static DateTime? _optionalDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException('Todo field "$key" must be an ISO-8601 string.');
    }
    return DateTime.parse(value);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoItem &&
        other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.archivedAt == archivedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, createdAt, completedAt, archivedAt);
  }
}
