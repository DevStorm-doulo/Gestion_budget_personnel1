import 'dart:io';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
// Source d'images pour le scan de reçus
// ─────────────────────────────────────────────
abstract class SourceImage {
  Future<File?> prendrePhoto();
  Future<File?> choisirGalerie();
  Future<bool> verifierPermissionCamera();
  Future<bool> verifierPermissionGalerie();
}

class SourceImageImpl implements SourceImage {
  final ImagePicker _picker;

  SourceImageImpl({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  @override
  Future<File?> prendrePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        return null;
      }

      return File(photo.path);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<File?> choisirGalerie() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> verifierPermissionCamera() async {
    // Le package image_picker gère automatiquement les permissions
    // On retourne true car les permissions sont demandées automatiquement
    return true;
  }

  @override
  Future<bool> verifierPermissionGalerie() async {
    // Le package image_picker gère automatiquement les permissions
    // On retourne true car les permissions sont demandées automatiquement
    return true;
  }
}
