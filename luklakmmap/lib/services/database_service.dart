import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Aggregates total cost and distance from trips for the user
  Future<Map<String, dynamic>> fetchUserTripStats(String userId) async {
    final response = await _client
        .from('trips')
        .select('cost, distance')
        .eq('user_id', userId);

    double totalCost = 0.0;
    int totalDistance = 0;

    for (final trip in response) {
      totalCost += (trip['cost'] as num).toDouble();
      totalDistance += (trip['distance'] as int);
    }

    return {
      'totalCost': totalCost,
      'totalDistance': totalDistance,
    };
  }
}
