import 'dart:io';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/home_map_page.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/home_tag_list.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/professional_card.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTagIndex = 0;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimize image size
    );

    if (image != null && context.mounted) {
      context.read<AuthBloc>().add(AvatarUpdated(image.path));
    }
  }

  // Mock Professionals Data with Social Links and GPS Coordinates (Santiago, Chile)
  final List<Professional> _mockProfessionals = [
    const Professional(
      id: '1',
      name: 'Julián',
      specialty: 'Plomería Experta',
      rating: 4.9,
      distance: 8.0,
      imageUrl: 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=400',
      isVerified: true,
      pricePerHour: 45,
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet, erat in ultricies ultrices, ex sem finibus tellus, ut blandit mi tortor sit lorem...',
      instagramUrl: 'https://instagram.com/julian',
      linkedinUrl: 'https://linkedin.com/in/julian',
      latitude: -33.4489,
      longitude: -70.6693,
    ),
    const Professional(
      id: '2',
      name: 'Pablo',
      specialty: 'Carpintería de Autor',
      rating: 4.7,
      distance: 12.0,
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
      isVerified: true,
      pricePerHour: 38,
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet, erat in ultricies ultrices, ex sem sem finibus tellus, ut blandit mi tortor sit lorem...',
      linkedinUrl: 'https://linkedin.com/in/pablo',
      twitterUrl: 'https://twitter.com/pablo',
      latitude: -33.4560,
      longitude: -70.6500,
    ),
    const Professional(
      id: '3',
      name: 'Patricia',
      specialty: 'Masajista Terapéutica',
      rating: 4.6,
      distance: 5.2,
      imageUrl: 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=400',
      isVerified: false,
      pricePerHour: 55,
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet, erat in ultricies ultrices, ex sem finibus tellus, ut blandit mi tortor sit lorem...',
      instagramUrl: 'https://instagram.com/patricia',
      latitude: -33.4400,
      longitude: -70.6800,
    ),
    const Professional(
      id: '4',
      name: 'Jorge',
      specialty: 'Gestión de Obras',
      rating: 4.5,
      distance: 15.0,
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400',
      isVerified: true,
      pricePerHour: 32,
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec laoreet, erat in ultricies ultrices, ex sem finibus tellus, ut blandit mi tortor sit lorem...',
      linkedinUrl: 'https://linkedin.com/in/jorge',
      latitude: -33.4600,
      longitude: -70.6400,
    ),
  ];

  // Filtering Logic
  List<Professional> get _filteredProfessionals {
    final list = List<Professional>.from(_mockProfessionals);
    if (_selectedTagIndex == 0) {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final tags = [l10n.homeTagNear, l10n.homeTagTopRated];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = 'User';
            if (state is AuthAuthenticated) {
              name = state.user.name;
            }

            return Row(
              children: [
                // Stylized Company Logo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: theme.colorScheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Greeting and User Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeGreeting(name),
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '¡Explora nuevas metas!',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Profile Picture (Interactive)
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: (state is AuthAuthenticated && state.user.avatarPath != null)
                          ? FileImage(File(state.user.avatarPath!)) as ImageProvider
                          : const NetworkImage(
                              'https://i.pravatar.cc/150?u=antigravity',
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar (Interactive for Map Search)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeMapPage(professionals: _mockProfessionals),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: AbsorbPointer(
                          child: TextField(
                            readOnly: true,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: l10n.homeSearchPlaceholder,
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.4),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Banner Carousel
            const HomeBannerCarousel(),
            const SizedBox(height: 10),
            // Tag Selection (Chips)
            HomeTagList(
              tags: tags,
              selectedIndex: _selectedTagIndex,
              onSelected: (index) {
                setState(() {
                  _selectedTagIndex = index;
                });
              },
              onViewAll: () {
                // Future Implementation for All view
              },
            ),
            const SizedBox(height: 16),
            // High-Fidelity Professional 2-Column Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredProfessionals.length,
                itemBuilder: (context, index) {
                  return ProfessionalCard(
                    professional: _filteredProfessionals[index],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '🚀 Más oportunidades para ti',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
