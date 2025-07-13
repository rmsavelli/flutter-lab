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
}
