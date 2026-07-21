import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';

class ImageCropperHelper {
  static Future<String?> cropImage({
    required String imagePath,
    required bool isSquare,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressQuality: 70,
      maxWidth: 1200,
      maxHeight: 1200,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: isSquare ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
          lockAspectRatio: isSquare,
          aspectRatioPresets: isSquare 
              ? [CropAspectRatioPreset.square]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
        IOSUiSettings(
          title: 'Ajustar Foto',
          aspectRatioLockEnabled: isSquare,
          resetAspectRatioEnabled: !isSquare,
          aspectRatioPresets: isSquare
              ? [CropAspectRatioPreset.square]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
      ],
    );
    return croppedFile?.path;
  }
}
