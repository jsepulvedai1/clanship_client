import 'package:flutter/material.dart';

class SeasonalColors {
  final Color? primary;
  final Color? secondary;
  final Color? accent;
  final Color? headerGradientStart;
  final Color? headerGradientEnd;
  final Color? searchBarBorder;
  final Color? navCenter;

  const SeasonalColors({
    this.primary,
    this.secondary,
    this.accent,
    this.headerGradientStart,
    this.headerGradientEnd,
    this.searchBarBorder,
    this.navCenter,
  });

  static Color? parseHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    try {
      String cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  factory SeasonalColors.fromJson(Map<String, dynamic> json) {
    return SeasonalColors(
      primary: parseHex(json['primary']?.toString()),
      secondary: parseHex(json['secondary']?.toString()),
      accent: parseHex(json['accent']?.toString()),
      headerGradientStart: parseHex(json['header_gradient_start']?.toString()),
      headerGradientEnd: parseHex(json['header_gradient_end']?.toString()),
      searchBarBorder: parseHex(json['search_bar_border']?.toString()),
      navCenter: parseHex(json['nav_center']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary != null
          ? '#${primary!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'secondary': secondary != null
          ? '#${secondary!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'accent': accent != null
          ? '#${accent!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'header_gradient_start': headerGradientStart != null
          ? '#${headerGradientStart!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'header_gradient_end': headerGradientEnd != null
          ? '#${headerGradientEnd!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'search_bar_border': searchBarBorder != null
          ? '#${searchBarBorder!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'nav_center': navCenter != null
          ? '#${navCenter!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
    };
  }
}

class SeasonalVisuals {
  final String? logoBadgeUrl;
  final String? navCenterIconUrl;
  final String? bannerImageUrl;
  final bool showTopGarland;
  final String garlandPosition; // BOTH, TOP, BOTTOM
  final bool showGarlandTop;
  final bool showGarlandBottom;
  final String? customGarlandUrl;
  final String particleEffect; // NONE, CONFETTI, SNOW, STARS

  const SeasonalVisuals({
    this.logoBadgeUrl,
    this.navCenterIconUrl,
    this.bannerImageUrl,
    this.showTopGarland = false,
    this.garlandPosition = 'BOTH',
    this.showGarlandTop = false,
    this.showGarlandBottom = false,
    this.customGarlandUrl,
    this.particleEffect = 'NONE',
  });

  static String? _sanitizeUrl(dynamic url) {
    if (url == null) return null;
    String s = url.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://api.clanship.cl')) {
      return s.replaceFirst('http://', 'https://');
    }
    return s;
  }

  factory SeasonalVisuals.fromJson(Map<String, dynamic> json) {
    final showTopGarland = json['show_top_garland'] == true;
    final garlandPos = json['garland_position']?.toString() ?? 'BOTH';
    final showTop = json.containsKey('show_garland_top')
        ? json['show_garland_top'] == true
        : (showTopGarland && (garlandPos == 'BOTH' || garlandPos == 'TOP'));
    final showBottom = json.containsKey('show_garland_bottom')
        ? json['show_garland_bottom'] == true
        : (showTopGarland && (garlandPos == 'BOTH' || garlandPos == 'BOTTOM'));

    return SeasonalVisuals(
      logoBadgeUrl: _sanitizeUrl(json['logo_badge_url']),
      navCenterIconUrl: _sanitizeUrl(json['nav_center_icon_url']),
      bannerImageUrl: _sanitizeUrl(json['banner_image_url']),
      showTopGarland: showTopGarland,
      garlandPosition: garlandPos,
      showGarlandTop: showTop,
      showGarlandBottom: showBottom,
      customGarlandUrl: _sanitizeUrl(json['custom_garland_url']),
      particleEffect: json['particle_effect']?.toString() ?? 'NONE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_badge_url': logoBadgeUrl,
      'nav_center_icon_url': navCenterIconUrl,
      'banner_image_url': bannerImageUrl,
      'show_top_garland': showTopGarland,
      'garland_position': garlandPosition,
      'show_garland_top': showGarlandTop,
      'show_garland_bottom': showGarlandBottom,
      'custom_garland_url': customGarlandUrl,
      'particle_effect': particleEffect,
    };
  }
}

class SeasonalCopy {
  final String? greetingPrefix;
  final String? promoBannerTitle;
  final String? promoBannerSubtitle;
  final String? promoBannerCtaText;
  final String promoBannerActionType; // REQUEST_JOB, SEARCH_TAG, DEEP_LINK
  final String? promoBannerActionValue;

  const SeasonalCopy({
    this.greetingPrefix,
    this.promoBannerTitle,
    this.promoBannerSubtitle,
    this.promoBannerCtaText,
    this.promoBannerActionType = 'REQUEST_JOB',
    this.promoBannerActionValue,
  });

  factory SeasonalCopy.fromJson(Map<String, dynamic> json) {
    return SeasonalCopy(
      greetingPrefix: json['greeting_prefix']?.toString(),
      promoBannerTitle: json['promo_banner_title']?.toString(),
      promoBannerSubtitle: json['promo_banner_subtitle']?.toString(),
      promoBannerCtaText: json['promo_banner_cta_text']?.toString(),
      promoBannerActionType: json['promo_banner_action_type']?.toString() ?? 'REQUEST_JOB',
      promoBannerActionValue: json['promo_banner_action_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting_prefix': greetingPrefix,
      'promo_banner_title': promoBannerTitle,
      'promo_banner_subtitle': promoBannerSubtitle,
      'promo_banner_cta_text': promoBannerCtaText,
      'promo_banner_action_type': promoBannerActionType,
      'promo_banner_action_value': promoBannerActionValue,
    };
  }
}

class SeasonalFeaturedTag {
  final int id;
  final String name;

  const SeasonalFeaturedTag({
    required this.id,
    required this.name,
  });

  factory SeasonalFeaturedTag.fromJson(Map<String, dynamic> json) {
    return SeasonalFeaturedTag(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class SeasonalCampaignModel {
  final int id;
  final String name;
  final String seasonType;
  final SeasonalColors colors;
  final SeasonalVisuals visuals;
  final SeasonalCopy copy;
  final List<SeasonalFeaturedTag> featuredTags;

  const SeasonalCampaignModel({
    required this.id,
    required this.name,
    required this.seasonType,
    required this.colors,
    required this.visuals,
    required this.copy,
    this.featuredTags = const [],
  });

  factory SeasonalCampaignModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['featured_tags'];
    List<SeasonalFeaturedTag> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((t) => SeasonalFeaturedTag.fromJson(t as Map<String, dynamic>)).toList();
    }

    return SeasonalCampaignModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      seasonType: json['season_type']?.toString() ?? 'CUSTOM',
      colors: SeasonalColors.fromJson(
        json['colors'] is Map<String, dynamic> ? json['colors'] : {},
      ),
      visuals: SeasonalVisuals.fromJson(
        json['visuals'] is Map<String, dynamic> ? json['visuals'] : {},
      ),
      copy: SeasonalCopy.fromJson(
        json['copy'] is Map<String, dynamic> ? json['copy'] : {},
      ),
      featuredTags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'season_type': seasonType,
      'colors': colors.toJson(),
      'visuals': visuals.toJson(),
      'copy': copy.toJson(),
      'featured_tags': featuredTags.map((t) => t.toJson()).toList(),
    };
  }
}
