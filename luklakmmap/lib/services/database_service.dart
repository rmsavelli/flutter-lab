import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location.dart';
import '../models/user.dart' as app_model;

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetches a full User object by ID
  Future<app_model.User?> fetchUser(String userId) async {
    final response = await _client
        .from('users')
        .select('id, name, target_cost, target_distance')
        .eq('id', userId)
        .single();

    return app_model.User.fromMap(response);
  }

  // Fetches total distance from trips for a given user
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

  // Fetches total cost from trips for a given user
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

  // Fetches all locations for a given user
  Future<List<Location>> fetchLocations(String userId) async {
    final response = await _client
        .from('locations')
        .select('id, name, address')
        .eq('user_id', userId);

    return response.map<Location>((item) => Location.fromMap(item)).toList();
  }
}
