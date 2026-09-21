import 'package:equatable/equatable.dart';
import 'package:clanship_cliente/core/theme/models/seasonal_campaign_model.dart';

abstract class SeasonalThemeEvent extends Equatable {
  const SeasonalThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadSeasonalTheme extends SeasonalThemeEvent {
  final String? baseUrl;
  const LoadSeasonalTheme({this.baseUrl});

  @override
  List<Object?> get props => [baseUrl];
}

class SeasonalThemeUpdated extends SeasonalThemeEvent {
  final SeasonalCampaignModel? campaign;
  const SeasonalThemeUpdated(this.campaign);

  @override
  List<Object?> get props => [campaign];
}
