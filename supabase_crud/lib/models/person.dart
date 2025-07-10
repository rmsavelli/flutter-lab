class Person {
  final int id;
  final String name;
  final int age;
  final bool isActive;
  final DateTime createdAt;

  Person({
    required this.id,
    required this.name,
    required this.age,
    required this.isActive,
    required this.createdAt,
  });

  // Convert Map (from Supabase) → Person
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Convert Person → Map (to Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Optional: a copyWith method for convenience
  Person copyWith({
    int? id,
    String? name,
    int? age,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}