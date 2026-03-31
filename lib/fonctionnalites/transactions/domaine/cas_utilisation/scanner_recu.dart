import 'package:dartz/dartz.dart';
import '../entites/resultat_scan.dart';
import '../entites/echec_scan.dart';
import '../../donnees/sources_donnees/source_reconnaissance_recu.dart';
import '../../donnees/sources_donnees/source_image.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Scanner un reçu
// ─────────────────────────────────────────────
class ScannerRecu {
  final SourceReconnaissanceRecu _sourceReconnaissance;
  final SourceImage _sourceImage;

  ScannerRecu({
    required SourceReconnaissanceRecu sourceReconnaissance,
    required SourceImage sourceImage,
  })  : _sourceReconnaissance = sourceReconnaissance,
        _sourceImage = sourceImage;

  /// Exécute le scan depuis la caméra
  Future<Either<EchecScan, ResultatScan>> executerDepuisCamera() async {
    try {
      // Prendre la photo
      final image = await _sourceImage.prendrePhoto();

      if (image == null) {
        // L'utilisateur a annulé ou la permission a été refusée
        final permissionAccordee = await _sourceImage.verifierPermissionCamera();
        if (!permissionAccordee) {
          return Left(EchecScan.permissionRefusee());
        }
        // L'utilisateur a annulé
        return Left(EchecScan.erreurFichier());
      }

      // Analyser l'image
      final resultat = await _sourceReconnaissance.analyserImage(image);
      return Right(resultat);
    } on EchecScan catch (e) {
      return Left(e);
    } catch (e) {
      return Left(EchecScan.erreurMLKit());
    }
  }

  /// Exécute le scan depuis la galerie
  Future<Either<EchecScan, ResultatScan>> executerDepuisGalerie() async {
    try {
      // Choisir l'image
      final image = await _sourceImage.choisirGalerie();

      if (image == null) {
        // L'utilisateur a annulé ou la permission a été refusée
        final permissionAccordee = await _sourceImage.verifierPermissionGalerie();
        if (!permissionAccordee) {
          return Left(EchecScan.permissionRefusee());
        }
        // L'utilisateur a annulé
        return Left(EchecScan.erreurFichier());
      }

      // Analyser l'image
      final resultat = await _sourceReconnaissance.analyserImage(image);
      return Right(resultat);
    } on EchecScan catch (e) {
      return Left(e);
    } catch (e) {
      return Left(EchecScan.erreurMLKit());
    }
  }
}
