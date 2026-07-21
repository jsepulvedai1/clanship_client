class ProfessionalDocument {
  final String id;
  final String name;
  final String fileUrl;
  final String status;
  final String? rejectionReason;

  const ProfessionalDocument({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.status,
    this.rejectionReason,
  });
}

class Professional {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final double distance;
  final String imageUrl;
  final double pricePerHour;
  final String description;
  final bool isVerified;
  final String? instagramUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? tiktokUrl;
  final String? facebookUrl;
  final double latitude;
  final double longitude;
  final List<String> galleryImages;
  final List<ProfessionalDocument> documents;
  final bool acceptsUrgency;
  final bool isFavorite;
  final String? specialtyIconUrl;
  final String? specialtyColor;
  final List<String> tags;
  final List<String> synonyms;

  const Professional({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.pricePerHour,
    required this.description,
    this.isVerified = false,
    this.acceptsUrgency = false,
    this.instagramUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.tiktokUrl,
    this.facebookUrl,
    required this.latitude,
    required this.longitude,
    this.galleryImages = const [],
    this.documents = const [],
    this.isFavorite = false,
    this.specialtyIconUrl,
    this.specialtyColor,
    this.tags = const [],
    this.synonyms = const [],
  });

  Professional copyWith({
    String? id,
    String? name,
    String? specialty,
    double? rating,
    double? distance,
    String? imageUrl,
    double? pricePerHour,
    String? description,
    bool? isVerified,
    bool? acceptsUrgency,
    String? instagramUrl,
    String? linkedinUrl,
    String? twitterUrl,
    String? tiktokUrl,
    String? facebookUrl,
    double? latitude,
    double? longitude,
    List<String>? galleryImages,
    List<ProfessionalDocument>? documents,
    bool? isFavorite,
    String? specialtyIconUrl,
    String? specialtyColor,
    List<String>? tags,
    List<String>? synonyms,
  }) {
    return Professional(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      acceptsUrgency: acceptsUrgency ?? this.acceptsUrgency,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      galleryImages: galleryImages ?? this.galleryImages,
      documents: documents ?? this.documents,
      isFavorite: isFavorite ?? this.isFavorite,
      specialtyIconUrl: specialtyIconUrl ?? this.specialtyIconUrl,
      specialtyColor: specialtyColor ?? this.specialtyColor,
      tags: tags ?? this.tags,
      synonyms: synonyms ?? this.synonyms,
    );
  }

  String get formattedDistance {
    if (distance < 1.0) {
      final meters = (distance * 1000).round();
      return '$meters m';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }
}
