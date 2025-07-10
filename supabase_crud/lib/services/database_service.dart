import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

class DatabaseService {
  // Fetch all people
  Future<List<Map<String, dynamic>>> fetchPeople() async {
    final response = await supabase
        .from('people')
        .select()
        .order('id');
    return List<Map<String, dynamic>>.from(response);
  }

  // Create a new person
  Future<void> createPerson({
    required String name,
    required int age,
    required bool isActive,
  }) async {
    await supabase.from('people').insert({
      'name': name,
      'age': age,
      'is_active': isActive,
    });
  }

  // Update a person
  Future<void> updatePerson({
    required int id,
    required String name,
    required int age,
    required bool isActive,
  }) async {
    await supabase.from('people').update({
      'name': name,
      'age': age,
      'is_active': isActive,
    }).eq('id', id);
  }

  // Delete a person
  Future<void> deletePerson(int id) async {
    await supabase.from('people').delete().eq('id', id);
  }
}