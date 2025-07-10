import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/person.dart'; // no topo

final SupabaseClient supabase = Supabase.instance.client;

class DatabaseService {
  // Fetch all people
  Future<List<Person>> fetchPeople() async {
    final response = await supabase.from('people').select().order('id');
    return (response as List)
        .map((item) => Person.fromMap(item))
        .toList();
  }

  // Create a new person
  Future<void> createPerson(Person person) async {
    await supabase.from('people').insert({
      'name': person.name,
      'age': person.age,
      'is_active': person.isActive,
    });
  }

  // Update a person
  Future<void> updatePerson(Person person) async {
    await supabase.from('people').update({
      'name': person.name,
      'age': person.age,
      'is_active': person.isActive,
    }).eq('id', person.id);
  }

  Future<void> deletePerson(int id) async {
    await supabase.from('people').delete().eq('id', id);
  }
}