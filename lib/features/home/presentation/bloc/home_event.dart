import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchNearbyProfessionals extends HomeEvent {
  final double latitude;
  final double longitude;
  final double? radius;

  const FetchNearbyProfessionals({
    required this.latitude,
    required this.longitude,
    this.radius,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class SearchProfessionalsRequested extends HomeEvent {
  final String query;

  const SearchProfessionalsRequested(this.query);

  @override
  List<Object?> get props => [query];
}
