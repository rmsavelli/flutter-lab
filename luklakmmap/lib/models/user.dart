class User {
  final String id;
  final String? name;
  final String? email;
  final String nif;
  final String? homeAddress;
  final String? licensePlate;
  final double targetCost;
  final double targetDistance;
  final String targetRatio;

  User({
    required this.id,
    this.name,
    this.email,
    required this.nif,
    this.homeAddress,
    this.licensePlate,
    required this.targetCost,
    required this.targetDistance,
    required this.targetRatio,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      nif: map['nif'] ?? '',
      homeAddress: map['home_address'] as String?,
      licensePlate: map['license_plate'] as String?,
      targetCost: (map['target_cost'] as num?)?.toDouble() ?? 0.0,
      targetDistance: (map['target_distance'] as num?)?.toDouble() ?? 0.0,
      targetRatio: map['target_ratio'] ?? '0.0',
    );
  }
}
