class ChatSession {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isStarred;

  ChatSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isStarred = false,
  });

  ChatSession copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isStarred,
  }) {
    return ChatSession(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}
