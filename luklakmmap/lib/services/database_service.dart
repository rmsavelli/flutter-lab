import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetches the user's name from the 'users' table given their ID.
  Future<String?> fetchName(String userId) async {
    final userResponse = await _client
        .from('users')
        .select('name')
        .eq('id', userId)
        .single();

    return userResponse['name'] as String?;
  }
}
