import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';

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

  // Flat list of matching Level 3 subtags + Level 2 tags for search
  List<Map<String, dynamic>> _getFlatSearchResults() {
    if (_searchQuery.isEmpty) return [];

    final List<Map<String, dynamic>> results = [];
    final queryLower = _searchQuery.toLowerCase();

    for (final spec in widget.specialties) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        if (subtags.isEmpty) {
          final tagName = tag['name'] as String;
          if (tagName.toLowerCase().contains(queryLower)) {
            results.add({
              'type': 'tag',
              'id': int.parse(tag['id'].toString()),
              'name': tagName,
              'tag_name': tagName,
              'spec_name': spec['name'] as String,
            });
          }
        } else {
          for (final subtag in subtags) {
            final subtagName = subtag['name'] as String;
            final tagName = tag['name'] as String;
            if (subtagName.toLowerCase().contains(queryLower) ||
                tagName.toLowerCase().contains(queryLower)) {
              results.add({
                'type': 'subtag',
                'id': int.parse(subtag['id'].toString()),
                'name': subtagName,
                'tag_name': tagName,
                'spec_name': spec['name'] as String,
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
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return Icons.plumbing_rounded;
    if (n.contains('pint')) return Icons.format_paint_rounded;
    if (n.contains('jard')) return Icons.local_florist_rounded;
    if (n.contains('limp')) return Icons.cleaning_services_rounded;
    if (n.contains('carp')) return Icons.handyman_rounded;
    if (n.contains('clim')) return Icons.ac_unit_rounded;
    return Icons.work_outline_rounded;
  }

  // Color Mapping Helper (Container Background)
  Color _getSpecialtyColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFFE2FBE9);
    if (n.contains('const') || n.contains('remod')) return const Color(0xFFE3F2FD);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return const Color(0xFFE0F7FA);
    if (n.contains('pint')) return const Color(0xFFF3E5F5);
    if (n.contains('jard')) return const Color(0xFFF1F8E9);
    if (n.contains('limp')) return const Color(0xFFFFF3E0);
    if (n.contains('carp')) return const Color(0xFFE0F2F1);
    if (n.contains('clim')) return const Color(0xFFECEFF1);
    return const Color(0xFFF5F5F5);
  }

  // Color Mapping Helper (Icon Color)
  Color _getSpecialtyIconColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFF0F973D);
    if (n.contains('const') || n.contains('remod')) return const Color(0xFF1565C0);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return const Color(0xFF00838F);
    if (n.contains('pint')) return const Color(0xFF6A1B9A);
    if (n.contains('jard')) return const Color(0xFF558B2F);
    if (n.contains('limp')) return const Color(0xFFEF6C00);
    if (n.contains('carp')) return const Color(0xFF00695C);
    if (n.contains('clim')) return const Color(0xFF37474F);
    return const Color(0xFF616161);
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
    if (n.contains('techo') || n.contains('gotera')) return Icons.roofing_rounded;
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
          // Esto evita que Flutter destruya el TextField al cambiar de rama
          // if/else, lo que hacía perder el foco tras la primera letra.
          _buildSearchBar(theme),

          // ─── Contenido dinámico según estado de búsqueda / navegación
          if (_searchQuery.isNotEmpty) ...[
            const Divider(height: 1),
            Expanded(child: _buildSearchResultsList(theme)),
            _buildBottomActionBar(
              theme,
              onPressedApply: () {
                Navigator.pop(context);
                widget.onApply(_selectedTagIds, _selectedSubtagIds);
              },
              onPressedCancel: () {
                _searchSheetController.clear();
              },
              cancelText: 'Limpiar búsqueda',
            ),
          ] else ...[
            if (_currentView == 0) ...[
              _buildHeader(theme, 'Filtrar Servicios', showClear: true),
              _buildInfoTip(theme),
              Expanded(child: _buildCategoriesView(theme)),
              _buildBottomActionBar(
                theme,
                onPressedApply: () {
                  Navigator.pop(context);
                  widget.onApply(_selectedTagIds, _selectedSubtagIds);
                },
                onPressedCancel: () {
                  Navigator.pop(context);
                },
                cancelText: 'Cancelar',
              ),
            ] else if (_currentView == 1) ...[
              _buildHeader(
                theme,
                _activeSpecialty!['name'] as String,
                onBack: () {
                  setState(() {
                    _currentView = 0;
                    _activeSpecialty = null;
                  });
                },
              ),
              _buildBreadcrumb(theme, 'Categoría', _activeSpecialty!['name'] as String),
              Expanded(child: _buildSubcategoriesView(theme)),
              _buildBottomActionBar(
                theme,
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
                cancelText: 'Cancelar',
              ),
            ] else if (_currentView == 2) ...[
              _buildHeader(
                theme,
                _activeTag!['name'] as String,
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
                cancelText: 'Cancelar',
                selectedCountText: '${_getTagSelectedCount(_activeTag!)} servicios seleccionados',
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(ThemeData theme, String title, {bool showClear = false, VoidCallback? onBack}) {
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
              child: const Text(
                'Limpiar todo',
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
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          Text(
            ' $child',
            style: const TextStyle(
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
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppColors.primary.withOpacity(0.4)
                : theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: TextField(
          controller: _searchSheetController,
          decoration: InputDecoration(
            hintText: 'Buscar servicio',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 15,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
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
  Widget _buildInfoTip(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Navega y selecciona los servicios que necesitas',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 1: Categories View
  Widget _buildCategoriesView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: widget.specialties.length,
      itemBuilder: (context, index) {
        final spec = widget.specialties[index];
        final name = spec['name'] as String;
        final tags = spec['tags'] as List<dynamic>? ?? [];
        final selectedCount = _getSpecialtySelectedCount(spec);

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
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  // Colored Circle Container with Custom Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getSpecialtyColor(name),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getSpecialtyIcon(name),
                      color: _getSpecialtyIconColor(name),
                      size: 22,
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
                          '${tags.length} subcategorías',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selected Count Badge & Chevron
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
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
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
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
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        final selectedCount = _getTagSelectedCount(tag);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (subtags.isEmpty) {
                // Fallback for tags without subtags
                final tagId = int.parse(tag['id'].toString());
                setState(() {
                  if (_selectedTagIds.contains(tagId)) {
                    _selectedTagIds.remove(tagId);
                  } else {
                    _selectedTagIds.add(tagId);
                  }
                });
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
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTagIcon(name),
                      color: AppColors.primary,
                      size: 22,
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
                          subtags.isEmpty ? 'Servicio General' : '${subtags.length} servicios',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkbox for empty-child fallback, or count badge for parent tag
                  if (subtags.isEmpty) ...[
                    Checkbox(
                      value: _selectedTagIds.contains(int.parse(tag['id'].toString())),
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
                        decoration: const BoxDecoration(
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
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primary,
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  Widget _buildSearchResultsList(ThemeData theme) {
    final results = _getFlatSearchResults();

    if (results.isEmpty) {
      return const Center(child: Text('No se encontraron servicios.'));
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

        final isSelected = isTag ? _selectedTagIds.contains(id) : _selectedSubtagIds.contains(id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isTag) {
                  if (isSelected) {
                    _selectedTagIds.remove(id);
                  } else {
                    _selectedTagIds.add(id);
                  }
                } else {
                  if (isSelected) {
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primary,
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
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$specName > $tagName',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
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
    ThemeData theme, {
    required VoidCallback onPressedApply,
    required VoidCallback onPressedCancel,
    required String cancelText,
    String? selectedCountText,
  }) {
    final countText = selectedCountText ?? '$_totalSelectedCount filtros seleccionados';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected count label
          Text(
            countText,
            style: const TextStyle(
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
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
