import '../../../../core/erreurs/echecs.dart';

// ─────────────────────────────────────────────
// Types d'échec pour le scan de reçus
// ─────────────────────────────────────────────
enum TypeEchecScan {
  permissionRefusee,
  imageFloue,
  aucuneDonneeDetectee,
  erreurMLKit,
  erreurFichier,
  formatInvalide,
}

// ─────────────────────────────────────────────
// Classe d'erreur dédiée au scan de reçus
// ─────────────────────────────────────────────
class EchecScan extends Echec {
  final TypeEchecScan type;

  const EchecScan({
    required String message,
    required this.type,
  }) : super(message);

  /// Crée une erreur pour permission refusée
  factory EchecScan.permissionRefusee() {
    return const EchecScan(
      message: 'L\'accès à la caméra est nécessaire pour scanner les reçus',
      type: TypeEchecScan.permissionRefusee,
    );
  }

  /// Crée une erreur pour image floue
  factory EchecScan.imageFloue() {
    return const EchecScan(
      message: 'L\'image semble floue. Essayez avec une photo plus nette.',
      type: TypeEchecScan.imageFloue,
    );
  }

  /// Crée une erreur pour aucune donnée détectée
  factory EchecScan.aucuneDonneeDetectee() {
    return const EchecScan(
      message: 'Aucun montant détecté. Veuillez remplir manuellement.',
      type: TypeEchecScan.aucuneDonneeDetectee,
    );
  }

  /// Crée une erreur pour erreur ML Kit
  factory EchecScan.erreurMLKit() {
    return const EchecScan(
      message: 'Erreur lors de l\'analyse. Veuillez réessayer.',
      type: TypeEchecScan.erreurMLKit,
    );
  }

  /// Crée une erreur pour fichier invalide
  factory EchecScan.erreurFichier() {
    return const EchecScan(
      message: 'Le fichier image n\'est pas valide.',
      type: TypeEchecScan.erreurFichier,
    );
  }

  /// Crée une erreur pour format invalide
  factory EchecScan.formatInvalide() {
    return const EchecScan(
      message: 'Le format de l\'image n\'est pas supporté.',
      type: TypeEchecScan.formatInvalide,
    );
  }
}
