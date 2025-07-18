class Trip {
  final int? id;
  final DateTime beginDate;
  final String justification;
  final double distance;
  final double cost;
  final int originLocationId;
  final int destinationLocationId;

  Trip({
    this.id,
    required this.beginDate,
    required this.justification,
    required this.distance,
    required this.cost,
    required this.originLocationId,
    required this.destinationLocationId,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as int,
      beginDate: DateTime.parse(map['begin_date']),
      justification: map['justification'] ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      originLocationId: map['origin_location'] ?? 0,
      destinationLocationId: map['destination_location'] ?? 0,
    );
  }
}
