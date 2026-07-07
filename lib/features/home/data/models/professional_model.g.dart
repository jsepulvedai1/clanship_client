// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessionalModel _$ProfessionalModelFromJson(Map<String, dynamic> json) =>
    ProfessionalModel(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      address: json['address'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      latitude: _doubleFromAny(json['latitude']),
      longitude: _doubleFromAny(json['longitude']),
      professionalProfile: json['professionalProfile'] == null
          ? null
          : ProfessionalProfileModel.fromJson(
              json['professionalProfile'] as Map<String, dynamic>,
            ),
      isFavorite: json['isFavorite'] as bool?,
    );

Map<String, dynamic> _$ProfessionalModelToJson(ProfessionalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'avatarUrl': instance.avatarUrl,
      'address': instance.address,
      'isAvailable': instance.isAvailable,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'professionalProfile': instance.professionalProfile,
      'isFavorite': instance.isFavorite,
    };

ProfessionalProfileModel _$ProfessionalProfileModelFromJson(
  Map<String, dynamic> json,
) => ProfessionalProfileModel(
  specialty: json['specialty'] == null
      ? null
      : SpecialtyModel.fromJson(json['specialty'] as Map<String, dynamic>),
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
      ?.map(
        (e) => ProfessionalDocumentModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ProfessionalProfileModelToJson(
  ProfessionalProfileModel instance,
) => <String, dynamic>{
  'specialty': instance.specialty,
  'hourlyRate': instance.hourlyRate,
  'rating': instance.rating,
  'bio': instance.bio,
  'facebookUrl': instance.facebookUrl,
  'instagramUrl': instance.instagramUrl,
  'tiktokUrl': instance.tiktokUrl,
  'photos': instance.photos,
  'documents': instance.documents,
};

SpecialtyModel _$SpecialtyModelFromJson(Map<String, dynamic> json) =>
    SpecialtyModel(
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$SpecialtyModelToJson(SpecialtyModel instance) =>
    <String, dynamic>{'name': instance.name, 'iconUrl': instance.iconUrl};

PortfolioPhotoModel _$PortfolioPhotoModelFromJson(Map<String, dynamic> json) =>
    PortfolioPhotoModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$PortfolioPhotoModelToJson(
  PortfolioPhotoModel instance,
) => <String, dynamic>{'id': instance.id, 'imageUrl': instance.imageUrl};

ProfessionalDocumentModel _$ProfessionalDocumentModelFromJson(
  Map<String, dynamic> json,
) => ProfessionalDocumentModel(
  id: json['id'] as String,
  name: json['name'] as String,
  fileUrl: json['fileUrl'] as String?,
  status: json['status'] as String,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$ProfessionalDocumentModelToJson(
  ProfessionalDocumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'fileUrl': instance.fileUrl,
  'status': instance.status,
  'rejectionReason': instance.rejectionReason,
};
