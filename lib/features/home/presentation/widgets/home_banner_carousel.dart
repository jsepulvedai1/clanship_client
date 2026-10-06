import 'dart:convert';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:http/http.dart' as http;
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradient;
  final String ctaText;
  final String? externalLink;
  final String? internalRoute;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradient,
    this.ctaText = 'Ver más',
    this.externalLink,
    this.internalRoute,
  });
}

class HomeBannerCarousel extends StatefulWidget {
  final List<BannerItem>? banners;

  const HomeBannerCarousel({super.key, this.banners});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _current = 0;
  List<BannerItem> _dynamicBanners = [];
  bool _isLoading = true;

  final List<BannerItem> _defaultBanners = [
    BannerItem(
      title: 'Expertos a domicilio',
      subtitle: 'Encuentra al profesional ideal para tu hogar.',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      gradient: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
    ),
    BannerItem(
      title: 'Servicios de confianza',
      subtitle: 'Trabajos garantizados y profesionales verificados.',
      imageUrl: 'https://images.unsplash.com/photo-1542013936693-884638332954?w=800',
      gradient: [
        AppColors.secondary,
        AppColors.secondary.withValues(alpha: 0.7),
      ],
    ),
    BannerItem(
      title: 'Atención rápida',
      subtitle: 'Conecta al instante con expertos en tu zona.',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
      gradient: [AppColors.accent, AppColors.accent.withValues(alpha: 0.7)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      String cleanBaseUrl = EnvConfig.instance.baseUrl.replaceAll('/graphql/', '').replaceAll('/graphql', '');
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }
      final uri = Uri.parse('$cleanBaseUrl/api/v1/banners/?app_type=CLIENT');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> bannersJson = data['banners'] ?? [];
        
        if (bannersJson.isNotEmpty) {
          List<BannerItem> fetchedBanners = [];
          for (var b in bannersJson) {
            Color startColor = _hexToColor(b['gradient_start'] ?? '#4299e1');
            Color endColor = _hexToColor(b['gradient_end'] ?? '#2b6cb0');
            
            fetchedBanners.add(BannerItem(
              title: b['title'] ?? '',
              subtitle: b['subtitle'] ?? '',
              imageUrl: b['image_url'] ?? '',
              gradient: [startColor, endColor],
              ctaText: b['cta_text'] ?? 'Ver más',
              externalLink: b['external_link'],
              internalRoute: b['internal_route'],
            ));
          }
          if (mounted) {
            setState(() {
              _dynamicBanners = fetchedBanners;
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Color _hexToColor(String code) {
    if (code.startsWith('#')) code = code.substring(1);
    if (code.length == 6) code = 'FF$code';
    try {
      return Color(int.parse(code, radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading && widget.banners == null) {
      return const SizedBox(
        height: 130,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    List<BannerItem> displayBanners = _defaultBanners;
    if (widget.banners != null && widget.banners!.isNotEmpty) {
      displayBanners = widget.banners!;
    } else if (_dynamicBanners.isNotEmpty) {
      displayBanners = _dynamicBanners;
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 130,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: displayBanners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: banner.gradient.first.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image or gradient fallback
                        Positioned.fill(
                          child: banner.imageUrl.isNotEmpty
                            ? Image.network(
                                banner.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: banner.gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: banner.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                        ),
                        // Dark overlay gradient for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      banner.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (banner.subtitle.isNotEmpty)
                                      Text(
                                        banner.subtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (banner.externalLink != null && banner.externalLink!.isNotEmpty) {
                                          final url = Uri.parse(banner.externalLink!);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        } else if (banner.internalRoute != null && banner.internalRoute!.isNotEmpty) {
                                          Navigator.of(context).pushNamed(banner.internalRoute!);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            banner.ctaText,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward_rounded, size: 14),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: displayBanners.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _current = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _current == entry.key ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: _current == entry.key
                      ? entry.value.gradient.first
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
