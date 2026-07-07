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
    );
  }
}
