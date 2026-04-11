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
  final double latitude;
  final double longitude;

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
    this.instagramUrl,
    this.linkedinUrl,
    this.twitterUrl,
    required this.latitude,
    required this.longitude,
  });
}
