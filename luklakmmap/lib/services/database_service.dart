import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Authenticates user and returns their ID if successful.
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Authentication failed');
    }

    return userId;
  }

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
