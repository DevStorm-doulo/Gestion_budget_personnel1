import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/conversion.dart';
import '../entites/devise.dart';

// ─────────────────────────────────────────────
// Interface du dépôt Conversion - Domaine
// ─────────────────────────────────────────────
abstract class DepotConversion {
  /// Convertit un montant d'une devise à une autre
  Future<Either<Echec, Conversion>> convertir({
    required double montant,
    required Devise deviseSource,
    required Devise deviseCible,
  });

  /// Obtient l'historique des conversions
  Future<Either<Echec, List<Conversion>>> obtenirHistorique();

  /// Sauvegarde une conversion dans l'historique
  Future<Either<Echec, void>> sauvegarderConversion(Conversion conversion);

  /// Supprime une conversion de l'historique
  Future<Either<Echec, void>> supprimerConversion(String id);

  /// Supprime tout l'historique
  Future<Either<Echec, void>> supprimerHistorique();
}
