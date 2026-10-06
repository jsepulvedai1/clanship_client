import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';

class ServicesFilterSheet extends StatefulWidget {
  final List<dynamic> specialties;
  final Set<int> initialSelectedTagIds;
  final Set<int> initialSelectedSubtagIds;
  final Function(Set<int> selectedTagIds, Set<int> selectedSubtagIds) onApply;

  const ServicesFilterSheet({
    super.key,
    required this.specialties,
    required this.initialSelectedTagIds,
    required this.initialSelectedSubtagIds,
    required this.onApply,
  });

  @override
  State<ServicesFilterSheet> createState() => _ServicesFilterSheetState();
}

class _ServicesFilterSheetState extends State<ServicesFilterSheet> {
  // Navigation State
  // 0: Categories (Level 1)
  // 1: Subcategories (Level 2)
  // 2: Services (Level 3)
  int _currentView = 0;

  // Selected parent nodes for detail views
  Map<String, dynamic>? _activeSpecialty;
  Map<String, dynamic>? _activeTag;

  // Selection states
  late Set<int> _selectedTagIds;
  late Set<int> _selectedSubtagIds;

  // Search input
  final TextEditingController _searchSheetController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTagIds = Set<int>.from(widget.initialSelectedTagIds);
    _selectedSubtagIds = Set<int>.from(widget.initialSelectedSubtagIds);
    _searchSheetController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchSheetController.removeListener(_onSearchChanged);
    _searchSheetController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchSheetController.text;
    });
  }

  // Count active selections overall
  int get _totalSelectedCount {
    return _selectedTagIds.length + _selectedSubtagIds.length;
  }

  // Count active selections for a Specialty
  int _getSpecialtySelectedCount(Map<String, dynamic> specialty) {
    int count = 0;
    final tags = specialty['tags'] as List<dynamic>? ?? [];
    for (final tag in tags) {
      final tagId = int.parse(tag['id'].toString());
      final subtags = tag['subtags'] as List<dynamic>? ?? [];
      if (subtags.isEmpty) {
        if (_selectedTagIds.contains(tagId)) {
          count++;
        }
      } else {
        for (final subtag in subtags) {
          final subtagId = int.parse(subtag['id'].toString());
          if (_selectedSubtagIds.contains(subtagId)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  // Count active selections for a Tag
  int _getTagSelectedCount(Map<String, dynamic> tag) {
    final tagId = int.parse(tag['id'].toString());
    final subtags = tag['subtags'] as List<dynamic>? ?? [];
    if (subtags.isEmpty) {
      return _selectedTagIds.contains(tagId) ? 1 : 0;
    }
    int count = 0;
    for (final subtag in subtags) {
      final subtagId = int.parse(subtag['id'].toString());
      if (_selectedSubtagIds.contains(subtagId)) {
        count++;
      }
    }
    return count;
  }

  bool _isSpecialtyFullySelected(Map<String, dynamic> specialty) {
    final tags = specialty['tags'] as List<dynamic>? ?? [];
    if (tags.isEmpty) return false;
    for (final tag in tags) {
      final tagId = int.parse(tag['id'].toString());
      final subtags = tag['subtags'] as List<dynamic>? ?? [];
      if (subtags.isEmpty) {
        if (!_selectedTagIds.contains(tagId)) return false;
      } else {
        for (final subtag in subtags) {
          final subtagId = int.parse(subtag['id'].toString());
          if (!_selectedSubtagIds.contains(subtagId)) return false;
        }
      }
    }
    return true;
  }

  bool _isTagFullySelected(Map<String, dynamic> tag) {
    final tagId = int.parse(tag['id'].toString());
    final subtags = tag['subtags'] as List<dynamic>? ?? [];
    if (subtags.isEmpty) {
      return _selectedTagIds.contains(tagId);
    }
    for (final subtag in subtags) {
      final subtagId = int.parse(subtag['id'].toString());
      if (!_selectedSubtagIds.contains(subtagId)) return false;
    }
    return true;
  }

  void _toggleSpecialtyCascade(Map<String, dynamic> specialty) {
    final isFullySelected = _isSpecialtyFullySelected(specialty);
    final tags = specialty['tags'] as List<dynamic>? ?? [];

    setState(() {
      for (final tag in tags) {
        final tagId = int.parse(tag['id'].toString());
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        if (subtags.isEmpty) {
          if (isFullySelected) {
            _selectedTagIds.remove(tagId);
          } else {
            _selectedTagIds.add(tagId);
          }
        } else {
          for (final subtag in subtags) {
            final subtagId = int.parse(subtag['id'].toString());
            if (isFullySelected) {
              _selectedSubtagIds.remove(subtagId);
            } else {
              _selectedSubtagIds.add(subtagId);
            }
          }
        }
      }
    });
  }

  void _toggleTagCascade(Map<String, dynamic> tag) {
    final tagId = int.parse(tag['id'].toString());
    final subtags = tag['subtags'] as List<dynamic>? ?? [];
    final isFullySelected = _isTagFullySelected(tag);

    setState(() {
      if (subtags.isEmpty) {
        if (isFullySelected) {
          _selectedTagIds.remove(tagId);
        } else {
          _selectedTagIds.add(tagId);
        }
      } else {
        for (final subtag in subtags) {
          final subtagId = int.parse(subtag['id'].toString());
          if (isFullySelected) {
            _selectedSubtagIds.remove(subtagId);
          } else {
            _selectedSubtagIds.add(subtagId);
          }
        }
      }
    });
  }

  // Flat list of matching Level 3 subtags + Level 2 tags for search
  List<Map<String, dynamic>> _getFlatSearchResults() {
    if (_searchQuery.isEmpty) return [];

    final List<Map<String, dynamic>> results = [];
    final queryLower = _searchQuery.toLowerCase();

    for (final spec in widget.specialties) {
      final specName = spec['name'] as String;
      final bool specMatches = specName.toLowerCase().contains(queryLower);
      final tags = spec['tags'] as List<dynamic>? ?? [];

      for (final tag in tags) {
        final tagName = tag['name'] as String;
        final bool tagMatches = tagName.toLowerCase().contains(queryLower);
        final subtags = tag['subtags'] as List<dynamic>? ?? [];

        if (subtags.isEmpty) {
          if (specMatches || tagMatches) {
            results.add({
              'type': 'tag',
              'id': int.parse(tag['id'].toString()),
              'name': tagName,
              'tag_name': tagName,
              'spec_name': specName,
            });
          }
        } else {
          for (final subtag in subtags) {
            final subtagName = subtag['name'] as String;
            if (specMatches ||
                tagMatches ||
                subtagName.toLowerCase().contains(queryLower)) {
              results.add({
                'type': 'subtag',
                'id': int.parse(subtag['id'].toString()),
                'name': subtagName,
                'tag_name': tagName,
                'spec_name': specName,
              });
            }
          }
        }
      }
    }
    return results;
  }

  // Icon Mapping Helper
  IconData _getSpecialtyIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('elec')) return Icons.bolt_rounded;
    if (n.contains('const') || n.contains('remod')) return Icons.home_rounded;
    if (n.contains('gas') || n.contains('agua') || n.contains('fit'))
      return Icons.plumbing_rounded;
    if (n.contains('pint')) return Icons.format_paint_rounded;
    if (n.contains('jard')) return Icons.local_florist_rounded;
    if (n.contains('limp')) return Icons.cleaning_services_rounded;
    if (n.contains('carp')) return Icons.handyman_rounded;
    if (n.contains('clim')) return Icons.ac_unit_rounded;
    return Icons.work_outline_rounded;
  }

  Widget _buildSpecialtyIconWidget(
    String name,
    String? iconUrl, {
    String? colorHex,
    double size = 22,
  }) {
    final fallbackIcon = Icon(
      _getSpecialtyIcon(name),
      color: _getSpecialtyIconColor(name, colorHex),
      size: size,
    );

    if (iconUrl != null && iconUrl.trim().isNotEmpty) {
      final cleanUrl = iconUrl.trim();
      final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => fallbackIcon,
        );
      } else {
        return Image.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => fallbackIcon,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallbackIcon;
          },
        );
      }
    }
    return fallbackIcon;
  }

  // Color Mapping Helper (Container Background)
  Color _getSpecialtyColor(String name, String? colorHex) {
    if (colorHex != null && colorHex.trim().isNotEmpty) {
      final base = _parseHexColor(colorHex);
      return base.withValues(alpha: 0.12);
    }
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFFE2FBE9);
    if (n.contains('const') || n.contains('remod'))
      return const Color(0xFFE3F2FD);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit'))
      return const Color(0xFFE0F7FA);
    if (n.contains('pint')) return const Color(0xFFF3E5F5);
    if (n.contains('jard')) return const Color(0xFFF1F8E9);
    if (n.contains('limp')) return const Color(0xFFFFF3E0);
    if (n.contains('carp')) return const Color(0xFFE0F2F1);
    if (n.contains('clim')) return const Color(0xFFECEFF1);
    return const Color(0xFFF5F5F5);
  }

  // Color Mapping Helper (Icon Color)
  Color _getSpecialtyIconColor(String name, String? colorHex) {
    if (colorHex != null && colorHex.trim().isNotEmpty) {
      return _parseHexColor(colorHex);
    }
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFF0F973D);
    if (n.contains('const') || n.contains('remod'))
      return const Color(0xFF1565C0);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit'))
      return const Color(0xFF00838F);
    if (n.contains('pint')) return const Color(0xFF6A1B9A);
    if (n.contains('jard')) return const Color(0xFF558B2F);
    if (n.contains('limp')) return const Color(0xFFEF6C00);
    if (n.contains('carp')) return const Color(0xFF00695C);
    if (n.contains('clim')) return const Color(0xFF37474F);
    return const Color(0xFF616161);
  }

  Color _parseHexColor(String? colorHex, {Color? defaultColor}) {
    final fallback = defaultColor ?? AppColors.primary;
    if (colorHex == null || colorHex.trim().isEmpty) return fallback;
    try {
      final hex = colorHex.trim().replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildTagIconWidget(String name, String? iconUrl, {double size = 22}) {
    final fallbackIcon = Icon(
      _getTagIcon(name),
      color: AppColors.primary,
      size: size,
    );

    if (iconUrl != null && iconUrl.trim().isNotEmpty) {
      final cleanUrl = iconUrl.trim();
      final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => fallbackIcon,
        );
      } else {
        return Image.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => fallbackIcon,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallbackIcon;
          },
        );
      }
    }
    return fallbackIcon;
  }

  // Tag Icon Mapping Helper
  IconData _getTagIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('instal')) return Icons.settings_suggest_rounded;
    if (n.contains('repara')) return Icons.build_rounded;
    if (n.contains('ilumin')) return Icons.lightbulb_outline_rounded;
    if (n.contains('certif')) return Icons.verified_rounded;
    if (n.contains('especial')) return Icons.star_rounded;
    if (n.contains('albañ')) return Icons.foundation_rounded;
    if (n.contains('termin')) return Icons.architecture_rounded;
    if (n.contains('techo') || n.contains('gotera'))
      return Icons.roofing_rounded;
    if (n.contains('piso')) return Icons.layers_rounded;
    if (n.contains('ventan')) return Icons.window_rounded;
    if (n.contains('cerraj')) return Icons.key_rounded;
    if (n.contains('hojal')) return Icons.hardware_rounded;
    if (n.contains('gasfit')) return Icons.plumbing_rounded;
    if (n.contains('calefon')) return Icons.local_fire_department_rounded;
    if (n.contains('redes')) return Icons.hub_rounded;
    if (n.contains('alcantar')) return Icons.water_damage_rounded;
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Barra de búsqueda SIEMPRE presente (nunca se desmonta)
          _buildSearchBar(theme, l10n),

          // ─── Contenido dinámico según estado de búsqueda / navegación
          if (_searchQuery.isNotEmpty) ...[
            const Divider(height: 1),
            Expanded(child: _buildSearchResultsList(theme, l10n)),
            _buildBottomActionBar(
              theme,
              l10n,
              onPressedApply: () {
                if (_totalSelectedCount == 0) {
                  final results = _getFlatSearchResults();
                  for (final item in results) {
                    final id = item['id'] as int;
                    if (item['type'] == 'tag') {
                      _selectedTagIds.add(id);
                    } else {
                      _selectedSubtagIds.add(id);
                    }
                  }
                }
                Navigator.pop(context);
                widget.onApply(_selectedTagIds, _selectedSubtagIds);
              },
              onPressedCancel: () {
                _searchSheetController.clear();
              },
              cancelText: l10n
                  .exploreClearFilters(0)
                  .replaceAll('(0)', '')
                  .trim(),
            ),
          ] else ...[
            if (_currentView == 0) ...[
              _buildHeader(
                theme,
                l10n.searchFilterSpecialty,
                l10n,
                showClear: true,
              ),
              _buildInfoTip(theme, l10n),
              Expanded(child: _buildCategoriesView(theme, l10n)),
              _buildBottomActionBar(
                theme,
                l10n,
                onPressedApply: () {
                  Navigator.pop(context);
                  widget.onApply(_selectedTagIds, _selectedSubtagIds);
                },
                onPressedCancel: () {
                  Navigator.pop(context);
                },
                cancelText: l10n.filterSheetCancel,
              ),
            ] else if (_currentView == 1) ...[
              _buildHeader(
                theme,
                _activeSpecialty!['name'] as String,
                l10n,
                onBack: () {
                  setState(() {
                    _currentView = 0;
                    _activeSpecialty = null;
                  });
                },
              ),
              _buildBreadcrumb(
                theme,
                l10n.filterSheetCategoryBreadcrumb,
                _activeSpecialty!['name'] as String,
              ),
              Expanded(child: _buildSubcategoriesView(theme)),
              _buildBottomActionBar(
                theme,
                l10n,
                onPressedApply: () {
                  Navigator.pop(context);
                  widget.onApply(_selectedTagIds, _selectedSubtagIds);
                },
                onPressedCancel: () {
                  setState(() {
                    _currentView = 0;
                    _activeSpecialty = null;
                  });
                },
                cancelText: l10n.filterSheetCancel,
              ),
            ] else if (_currentView == 2) ...[
              _buildHeader(
                theme,
                _activeTag!['name'] as String,
                l10n,
                onBack: () {
                  setState(() {
                    _currentView = 1;
                    _activeTag = null;
                  });
                },
              ),
              _buildBreadcrumb(
                theme,
                _activeSpecialty!['name'] as String,
                _activeTag!['name'] as String,
              ),
              Expanded(child: _buildServicesView(theme)),
              _buildBottomActionBar(
                theme,
                l10n,
                onPressedApply: () {
                  Navigator.pop(context);
                  widget.onApply(_selectedTagIds, _selectedSubtagIds);
                },
                onPressedCancel: () {
                  setState(() {
                    _currentView = 1;
                    _activeTag = null;
                  });
                },
                cancelText: l10n.filterSheetCancel,
                selectedCountText: l10n.filterSheetSelectedServices(
                  _getTagSelectedCount(_activeTag!),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(
    ThemeData theme,
    String title,
    AppLocalizations l10n, {
    bool showClear = false,
    VoidCallback? onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showClear)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTagIds.clear();
                  _selectedSubtagIds.clear();
                });
              },
              child: Text(
                l10n.filterSheetClearAll,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Search Header
  // Breadcrumb widget
  Widget _buildBreadcrumb(ThemeData theme, String parent, String child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Text(
            '$parent ',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          Text(
            ' $child',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar (siempre presente en el árbol para mantener el foco del TextField)
  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppColors.primary.withValues(alpha: 0.4)
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: TextField(
          controller: _searchSheetController,
          decoration: InputDecoration(
            hintText: l10n.filterSheetSearchPlaceholder,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () => _searchSheetController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // Lightbulb Helper tip
  Widget _buildInfoTip(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.filterSheetInfoTip,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 1: Categories View
  Widget _buildCategoriesView(ThemeData theme, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: widget.specialties.length,
      itemBuilder: (context, index) {
        final spec = widget.specialties[index];
        final name = spec['name'] as String;
        final iconUrl = spec['iconUrl'] as String?;
        final specColorHex = spec['color'] as String?;
        final tags = spec['tags'] as List<dynamic>? ?? [];
        final selectedCount = _getSpecialtySelectedCount(spec);
        final isFullySelected = _isSpecialtyFullySelected(spec);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _activeSpecialty = spec;
                _currentView = 1;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isFullySelected,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      _toggleSpecialtyCascade(spec);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Colored Circle Container with Custom Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getSpecialtyColor(name, specColorHex),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _buildSpecialtyIconWidget(
                        name,
                        iconUrl,
                        colorHex: specColorHex,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Specialty Text & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.filterSheetSubcategories(tags.length),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selected Count Badge & Chevron
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SCREEN 2: Subcategories View

  Widget _buildSubcategoriesView(ThemeData theme) {
    final tags = _activeSpecialty!['tags'] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final name = tag['name'] as String;
        final iconUrl = tag['iconUrl'] as String?;
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        final selectedCount = _getTagSelectedCount(tag);
        final isFullySelected = _isTagFullySelected(tag);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (subtags.isEmpty) {
                _toggleTagCascade(tag);
              } else {
                setState(() {
                  _activeTag = tag;
                  _currentView = 2;
                });
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isFullySelected,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      _toggleTagCascade(tag);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _buildTagIconWidget(name, iconUrl, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tag Text & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtags.isEmpty
                              ? 'Servicio General'
                              : '${subtags.length} servicios',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkbox for empty-child fallback, or count badge for parent tag
                  if (subtags.isEmpty) ...[
                    Checkbox(
                      value: _selectedTagIds.contains(
                        int.parse(tag['id'].toString()),
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        final tagId = int.parse(tag['id'].toString());
                        setState(() {
                          if (val == true) {
                            _selectedTagIds.add(tagId);
                          } else {
                            _selectedTagIds.remove(tagId);
                          }
                        });
                      },
                    ),
                  ] else ...[
                    if (selectedCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$selectedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SCREEN 3: Services View
  Widget _buildServicesView(ThemeData theme) {
    final subtags = _activeTag!['subtags'] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: subtags.length,
      itemBuilder: (context, index) {
        final subtag = subtags[index];
        final name = subtag['name'] as String;
        final subtagId = int.parse(subtag['id'].toString());
        final isSelected = _selectedSubtagIds.contains(subtagId);
        final colorHex = subtag['color'] as String?;
        final accentColor = _parseHexColor(
          colorHex,
          defaultColor: AppColors.primary,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSubtagIds.remove(subtagId);
                } else {
                  _selectedSubtagIds.add(subtagId);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withValues(alpha: 0.06) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedSubtagIds.add(subtagId);
                        } else {
                          _selectedSubtagIds.remove(subtagId);
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Flat Search Results List View
  Widget _buildSearchResultsList(ThemeData theme, AppLocalizations l10n) {
    final results = _getFlatSearchResults();

    if (results.isEmpty) {
      return Center(child: Text(l10n.filterSheetNoServices));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final id = item['id'] as int;
        final name = item['name'] as String;
        final tagName = item['tag_name'] as String;
        final specName = item['spec_name'] as String;
        final isTag = item['type'] == 'tag';

        final isSelected = isTag
            ? _selectedTagIds.contains(id)
            : _selectedSubtagIds.contains(id);
        final colorHex = item['color'] as String?;
        final accentColor = _parseHexColor(
          colorHex,
          defaultColor: AppColors.primary,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isTag) {
                  if (_selectedTagIds.contains(id)) {
                    _selectedTagIds.remove(id);
                  } else {
                    _selectedTagIds.add(id);
                  }
                } else {
                  if (_selectedSubtagIds.contains(id)) {
                    _selectedSubtagIds.remove(id);
                  } else {
                    _selectedSubtagIds.add(id);
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withValues(alpha: 0.06) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (isTag) {
                          if (val == true) {
                            _selectedTagIds.add(id);
                          } else {
                            _selectedTagIds.remove(id);
                          }
                        } else {
                          if (val == true) {
                            _selectedSubtagIds.add(id);
                          } else {
                            _selectedSubtagIds.remove(id);
                          }
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$specName > $tagName',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Bottom action bar widget matching the designs
  Widget _buildBottomActionBar(
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onPressedApply,
    required VoidCallback onPressedCancel,
    required String cancelText,
    String? selectedCountText,
  }) {
    final countText =
        selectedCountText ??
        l10n.filterSheetSelectedServices(_totalSelectedCount);

    final bool hasSelection = _totalSelectedCount > 0;
    final String buttonText = hasSelection ? "Aplicar filtros" : "Buscar";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected count label
          Text(
            countText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Green action button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressedApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Cancel text button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              onPressed: onPressedCancel,
              child: Text(
                cancelText,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
