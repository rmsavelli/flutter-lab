import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location.dart';
import '../models/trip.dart';
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

  Future<List<Trip>> fetchTripsForMonth(String userId, DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final response = await _client
        .from('trips')
        .select('id, begin_date, justification, distance, cost, origin_location, destination_location')
        .eq('user_id', userId)
        .gte('begin_date', firstDay.toIso8601String())
        .lt('begin_date', nextMonth.toIso8601String());

    return (response as List)
        .map((trip) => Trip.fromMap(trip as Map<String, dynamic>))
        .toList();
  }

  Future<double> fetchTripTotalDistance(String userId, DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final response = await _client
      .from('trips')
      .select('distance')
      .eq('user_id', userId)
      .gte('begin_date', firstDay.toIso8601String())
      .lt('begin_date', nextMonth.toIso8601String());

    double totalDistance = 0.0;
    for (final trip in response) {
      totalDistance += (trip['distance'] as num).toDouble();
    }

    return totalDistance;
  }

  Future<double> fetchTripTotalCost(String userId, DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final response = await _client
      .from('trips')
      .select('cost')
      .eq('user_id', userId)
      .gte('begin_date', firstDay.toIso8601String())
      .lt('begin_date', nextMonth.toIso8601String());

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

  Future<String> fetchLocationName(int locationId) async {
    final response = await _client
      .from('locations')
      .select('name')
      .eq('id', locationId)
      .single();

      return response['name'] ?? 'Unknown';
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

  Future<void> insertTrip(Trip trip, String userId) async {
    await _client.from('trips').insert({
      'user_id': userId,
      'begin_date': trip.beginDate.toIso8601String(),
      'justification': trip.justification,
      'distance': trip.distance,
      'cost': trip.cost,
      'origin_location': trip.originLocationId,
      'destination_location': trip.destinationLocationId,
    });
  }

  // UPDATE

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _client
      .from('users')
      .update(updates)
      .eq('id', userId);
  }

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
