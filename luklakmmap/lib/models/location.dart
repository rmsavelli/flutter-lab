class Location {
  final int id;
  final String name;
  final String address;
  final bool immutable;

  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.immutable
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      immutable: map['immutable'] as bool,
    );
  }
}
