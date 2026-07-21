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
      distance: _doubleFromAny(json['distance']),
      professionalProfile: json['professionalProfile'] == null
          ? null
          : ProfessionalProfileModel.fromJson(
              json['professionalProfile'] as Map<String, dynamic>,
            ),
      isFavorite: json['isFavorite'] as bool?,
      isEmergency: json['isEmergency'] as bool?,
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
      'distance': instance.distance,
      'professionalProfile': instance.professionalProfile,
      'isFavorite': instance.isFavorite,
      'isEmergency': instance.isEmergency,
    };

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
