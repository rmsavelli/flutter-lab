import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Authenticates user and returns their ID if successful.
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

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
