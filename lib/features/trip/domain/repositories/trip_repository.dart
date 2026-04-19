import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip_request.dart';

abstract class TripRepository {
  /// Creates addresses and a trip in Supabase.
  /// Returns the created [Trip] on success.
  Future<Trip> createTrip(TripRequest request);

  /// Returns all active/scheduled trips for the given client,
  /// ordered by [scheduledDatetime] ascending.
  Future<List<ScheduledTrip>> getScheduledTrips(String clientId);
}
