class User {
  final String id;
  final String name;
  final double targetCost;
  final int targetDistance;

  User({
    required this.id,
    required this.name,
    required this.targetCost,
    required this.targetDistance,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      targetCost: (map['target_cost'] as num?)?.toDouble() ?? 0.0,
      targetDistance: map['target_distance'] as int? ?? 0,
    );
  }
}
