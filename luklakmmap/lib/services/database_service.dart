import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch name, target_cost, and target_distance from users table
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final userResponse = await _client
        .from('users')
        .select('name, target_cost, target_distance')
        .eq('id', userId)
        .single();

    return {
      'name': userResponse['name'] as String,
      'target_cost': (userResponse['target_cost'] as num?)?.toDouble() ?? 0.0,
      'target_distance': userResponse['target_distance'] as int? ?? 0,
    };
  }
}
