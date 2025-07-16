import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location.dart';
import '../models/user.dart' as app_model;

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // FETCHES

  Future<app_model.User?> fetchUser(String userId) async {
    final response = await _client
        .from('users')
        .select('id, name, email, nif, home_address, license_plate, target_cost, target_distance, target_ratio')
        .eq('id', userId)
        .single();

    return app_model.User.fromMap(response);
  }

  Future<double> fetchTripTotalDistance(String userId) async {
    final response = await _client
      .from('trips')
      .select('distance')
      .eq('user_id', userId);

    double totalDistance = 0.0;
    for (final trip in response) {
      totalDistance += (trip['distance'] as num).toDouble();
    }

    return totalDistance;
  }

  Future<double> fetchTripTotalCost(String userId) async {
    final response = await _client
      .from('trips')
      .select('cost')
      .eq('user_id', userId);

    double totalCost = 0.0;
    for (final trip in response) {
      totalCost += (trip['cost'] as num).toDouble();
    }

    return totalCost;
  }

  Future<List<Location>> fetchLocations(String userId) async {
    final response = await _client
        .from('locations')
        .select('id, name, address, immutable')
        .eq('user_id', userId);

    return response.map<Location>((item) => Location.fromMap(item)).toList();
  }

  // INSERTS

  Future<void> insertLocation(Location location, String userId) async {
    await _client.from('locations').insert({
      'name': location.name,
      'address': location.address,
      'user_id': userId,
      'immutable': location.immutable
    });
  }

  // UPDATE

  Future<void> updateLocation(Location location) async {
    await _client
      .from('locations')
      .update({
        'name': location.name,
        'address': location.address,
        'immutable': location.immutable
      })
      .eq('id', location.id);
  }

  // DELETE

  Future<void> deleteLocation(int id) async {
    await _client
      .from('locations')
      .delete()
      .eq('id', id);
  }
}
