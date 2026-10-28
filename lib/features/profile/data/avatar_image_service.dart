import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AvatarImageService {
  AvatarImageService({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  Future<XFile?> pick(ImageSource source) => _picker.pickImage(
    source: source,
    imageQuality: 92,
    maxWidth: 2048,
    maxHeight: 2048,
    requestFullMetadata: false,
  );

  Future<CroppedFile?> crop(String sourcePath) => _cropper.cropImage(
    sourcePath: sourcePath,
    maxWidth: 1024,
    maxHeight: 1024,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Căn chỉnh ảnh đại diện',
        toolbarColor: const Color(0xFF071923),
        toolbarWidgetColor: const Color(0xFFFFD36C),
        activeControlsWidgetColor: const Color(0xFFD6A948),
        backgroundColor: const Color(0xFF020A10),
        cropFrameColor: const Color(0xFFFFD36C),
        lockAspectRatio: true,
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: 'Căn chỉnh ảnh đại diện',
        doneButtonTitle: 'Xong',
        cancelButtonTitle: 'Hủy',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );

  Future<int> fileLength(String path) => File(path).length();
}

final avatarImageServiceProvider = Provider<AvatarImageService>(
  (_) => AvatarImageService(),
);
