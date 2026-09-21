import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/theme/models/seasonal_campaign_model.dart';

class SeasonalThemeState extends Equatable {
  final SeasonalCampaignModel? campaign;
  final bool isLoaded;

  const SeasonalThemeState({
    this.campaign,
    this.isLoaded = false,
  });

  bool get hasActiveCampaign => campaign != null;

  Color get primaryColor => campaign?.colors.primary ?? AppColors.primary;
  Color get secondaryColor => campaign?.colors.secondary ?? AppColors.secondary;
  Color get accentColor => campaign?.colors.accent ?? AppColors.accent;

  Color get searchBarBorderColor =>
      campaign?.colors.searchBarBorder ?? accentColor;

  Color get navCenterColor =>
      campaign?.colors.navCenter ?? primaryColor;

  String? get navCenterIconUrl =>
      campaign?.visuals.navCenterIconUrl;

  bool get showTopGarland =>
      campaign?.visuals.showTopGarland ?? false;

  String get garlandPosition =>
      campaign?.visuals.garlandPosition ?? 'BOTH';

  bool get showGarlandTop =>
      campaign?.visuals.showGarlandTop ?? false;

  bool get showGarlandBottom =>
      campaign?.visuals.showGarlandBottom ?? false;

  String? get customGarlandUrl =>
      campaign?.visuals.customGarlandUrl;

  List<Color> get headerGradient {
    final start = campaign?.colors.headerGradientStart ?? AppColors.secondary;
    final end = campaign?.colors.headerGradientEnd ?? const Color(0xFF163E63);
    return [start, end];
  }

  SeasonalThemeState copyWith({
    SeasonalCampaignModel? campaign,
    bool? isLoaded,
    bool clearCampaign = false,
  }) {
    return SeasonalThemeState(
      campaign: clearCampaign ? null : (campaign ?? this.campaign),
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [campaign, isLoaded];
}
