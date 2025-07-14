class Location {
  final int id;
  final String name;
  final String address;

  Location({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
