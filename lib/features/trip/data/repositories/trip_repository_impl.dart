import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_app/features/trip/data/models/address_model.dart';
import 'package:kz_servicos_app/features/trip/data/models/scheduled_trip_model.dart';
import 'package:kz_servicos_app/features/trip/data/models/trip_model.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip_request.dart';
import 'package:kz_servicos_app/features/trip/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<Trip> createTrip(TripRequest request) async {
    // 1. Fetch trip service category
    final serviceCategoryId = await _fetchTripCategoryId();

    // 2. Create pickup address
    final pickupId = await _insertAddress(
      AddressModel.fromEntity(request.pickupAddress),
    );

    // 3. Create dropoff address
    final dropoffId = await _insertAddress(
      AddressModel.fromEntity(request.dropoffAddress),
    );

    // 4. Create trip
    final tripJson = TripModel.buildInsertJson(
      clientId: request.clientId,
      serviceCategoryId: serviceCategoryId,
      pickupAddressId: pickupId,
      dropoffAddressId: dropoffId,
      scheduledDatetime: request.scheduledDatetime,
      passengerCount: request.passengerCount,
      childrenCount: request.childrenCount,
      luggageCount: request.luggageCount,
      observations: request.combinedObservations,
      paymentMethod: request.paymentMethod,
    );

    final tripResponse = await _client
        .from('trips')
        .insert(tripJson)
        .select();

    if (tripResponse.isEmpty) {
      throw Exception('Failed to create trip: empty response');
    }

    return TripModel.fromJson(tripResponse.first).toEntity();
  }

  Future<String> _fetchTripCategoryId() async {
    final response = await _client
        .from('service_categories')
        .select('id, name, service_type')
        .eq('service_type', 'trip')
        .limit(1);

    if (response.isEmpty) {
      throw Exception(
        'Service category for trips not found. '
        'Ensure seed data exists in service_categories.',
      );
    }

    return response.first['id'] as String;
  }

  Future<String> _insertAddress(AddressModel address) async {
    final response = await _client
        .from('addresses')
        .insert(address.toJson())
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to create address: empty response');
    }

    return response.first['id'] as String;
  }

  static const _activeStatuses = [
    'open',
    'under_review',
    'searching_drivers',
    'awaiting_client_confirmation',
    'awaiting_driver_confirmation',
    'scheduled',
  ];

  @override
  Future<List<ScheduledTrip>> getScheduledTrips(String clientId) async {
    final response = await _client
        .from('trips')
        .select(
          '*, '
          'pickup_address:addresses!pickup_address_id(*), '
          'dropoff_address:addresses!dropoff_address_id(*), '
          'driver_profiles(provider_profiles(users(full_name)))',
        )
        .eq('client_id', clientId)
        .inFilter('status', _activeStatuses)
        .order('scheduled_datetime', ascending: true);

    return response
        .map((json) => ScheduledTripModel.fromJson(json).toEntity())
        .toList();
  }
}
