import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:json_annotation/json_annotation.dart';

part 'professional_model.g.dart';

@JsonSerializable()
class ProfessionalModel {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? address;
  final bool? isAvailable;
  @JsonKey(fromJson: _doubleFromAny)
  final double? latitude;
  @JsonKey(fromJson: _doubleFromAny)
  final double? longitude;
  final ProfessionalProfileModel? professionalProfile;
  final bool? isFavorite;

  ProfessionalModel({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.address,
    this.isAvailable,
    this.latitude,
    this.longitude,
    this.professionalProfile,
    this.isFavorite,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalModelToJson(this);

  Professional toEntity() {
    String displayName = '';
    if (firstName != null && firstName!.trim().isNotEmpty) {
      displayName = firstName!.trim();
      if (lastName != null && lastName!.trim().isNotEmpty) {
        displayName += ' ${lastName!.trim()}';
      }
    } else {
      displayName = username;
    }

    return Professional(
      id: id,
      name: displayName,
      specialty: professionalProfile?.specialty?.name ?? 'General',
      specialtyIconUrl: professionalProfile?.specialty?.iconUrl,
      rating: (professionalProfile?.rating ?? 0.0).toDouble(),
      distance: 0.0,
      imageUrl: avatarUrl ?? '',
      pricePerHour: (professionalProfile?.hourlyRate ?? 0.0).toDouble(),
      description: professionalProfile?.bio ?? '', // Mapeamos bio aquí
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      isVerified: true,
      isFavorite: isFavorite ?? false,
      facebookUrl: professionalProfile?.facebookUrl,
      instagramUrl: professionalProfile?.instagramUrl,
      tiktokUrl: professionalProfile?.tiktokUrl,
      galleryImages: professionalProfile?.photos?.map((p) => p.imageUrl).toList() ?? const [],
      documents: professionalProfile?.documents?.map((d) => d.toEntity()).toList() ?? const [],
    );
  }
}

double? _doubleFromAny(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

@JsonSerializable()
class ProfessionalProfileModel {
  final SpecialtyModel? specialty;
  @JsonKey(fromJson: _doubleFromAny)
  final double? hourlyRate;
  @JsonKey(fromJson: _doubleFromAny)
  final double? rating;
  final String? bio; // Nuevo campo
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final List<PortfolioPhotoModel>? photos;
  final List<ProfessionalDocumentModel>? documents;

  ProfessionalProfileModel({
    this.specialty,
    this.hourlyRate,
    this.rating,
    this.bio,
    this.facebookUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.photos,
    this.documents,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalProfileModelToJson(this);
}

@JsonSerializable()
class SpecialtyModel {
  final String name;
  final String? iconUrl;

  SpecialtyModel({required this.name, this.iconUrl});

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyModelToJson(this);
}

@JsonSerializable()
class PortfolioPhotoModel {
  final String id;
  final String imageUrl;

  PortfolioPhotoModel({
    required this.id,
    required this.imageUrl,
  });

  factory PortfolioPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioPhotoModelToJson(this);
}

@JsonSerializable()
class ProfessionalDocumentModel {
  final String id;
  final String name;
  final String? fileUrl;
  final String status;
  final String? rejectionReason;

  ProfessionalDocumentModel({
    required this.id,
    required this.name,
    this.fileUrl,
    required this.status,
    this.rejectionReason,
  });

  factory ProfessionalDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalDocumentModelToJson(this);

  ProfessionalDocument toEntity() {
    return ProfessionalDocument(
      id: id,
      name: name,
      fileUrl: fileUrl ?? '',
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
