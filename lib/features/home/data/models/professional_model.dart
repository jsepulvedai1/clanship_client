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
  @JsonKey(fromJson: _doubleFromAny)
  final double? distance;
  final ProfessionalProfileModel? professionalProfile;
  final bool? isFavorite;
  final bool? isEmergency;

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
    this.distance,
    this.professionalProfile,
    this.isFavorite,
    this.isEmergency,
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

    final List<String> synonymList = [];
    if (professionalProfile?.specialty?.synonyms != null &&
        professionalProfile!.specialty!.synonyms!.isNotEmpty) {
      final syns = professionalProfile!.specialty!.synonyms!
          .split(',')
          .map((s) => s.trim())
          .toList();
      synonymList.addAll(syns);
    }

    return Professional(
      id: id,
      name: displayName,
      specialty: professionalProfile?.specialty?.name ?? 'General',
      specialtyIconUrl: professionalProfile?.specialty?.iconUrl,
      specialtyColor: professionalProfile?.specialty?.color,
      rating: (professionalProfile?.rating ?? 0.0).toDouble(),
      distance: distance ?? 0.0,
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
      tags: [
        ...?professionalProfile?.tags,
        ...?professionalProfile?.subtags,
      ],
      synonyms: synonymList,
      acceptsUrgency: isEmergency ?? false,
    );
  }
}

double? _doubleFromAny(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class ProfessionalProfileModel {
  final SpecialtyModel? specialty;
  final double? hourlyRate;
  final double? rating;
  final String? bio;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final List<PortfolioPhotoModel>? photos;
  final List<ProfessionalDocumentModel>? documents;
  final List<String>? tags;
  final List<String>? subtags;

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
    this.tags,
    this.subtags,
  });

  factory ProfessionalProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfileModel(
      specialty: json['specialty'] != null
          ? SpecialtyModel.fromJson(json['specialty'] as Map<String, dynamic>)
          : null,
      hourlyRate: _doubleFromAny(json['hourlyRate']),
      rating: _doubleFromAny(json['rating']),
      bio: json['bio'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PortfolioPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => ProfessionalDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) {
            final name = e['name'] as String;
            final color = e['color'] as String? ?? '';
            return color.isNotEmpty ? '$name|$color' : name;
          })
          .toList(),
      subtags: (json['subtags'] as List<dynamic>?)
          ?.map((e) {
            final name = e['name'] as String;
            final color = e['color'] as String? ?? '';
            return color.isNotEmpty ? '$name|$color' : name;
          })
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'specialty': specialty?.toJson(),
    'hourlyRate': hourlyRate,
    'rating': rating,
    'bio': bio,
    'facebookUrl': facebookUrl,
    'instagramUrl': instagramUrl,
    'tiktokUrl': tiktokUrl,
    'photos': photos?.map((e) => e.toJson()).toList(),
    'documents': documents?.map((e) => e.toJson()).toList(),
  };
}

class SpecialtyModel {
  final String name;
  final String? iconUrl;
  final String? color;
  final String? synonyms;

  SpecialtyModel({required this.name, this.iconUrl, this.color, this.synonyms});

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      name: json['name'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      color: json['color'] as String?,
      synonyms: json['synonyms'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'iconUrl': iconUrl,
    'color': color,
    'synonyms': synonyms,
  };
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
