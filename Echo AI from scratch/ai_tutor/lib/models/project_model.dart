class ProjectModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> sessionIds;

  ProjectModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.sessionIds = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sessionIds: (json['sessionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'sessionIds': sessionIds,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? sessionIds,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      sessionIds: sessionIds ?? this.sessionIds,
    );
  }
}