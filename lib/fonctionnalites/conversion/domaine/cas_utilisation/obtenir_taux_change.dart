import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../donnees/sources_donnees/source_taux_change.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Obtenir les taux de change
// ─────────────────────────────────────────────
class ObtenirTauxChange {
  final SourceTauxChange sourceTauxChange;

  ObtenirTauxChange(this.sourceTauxChange);

  Future<Either<Echec, Map<String, double>>> executer(String deviseSource) async {
    try {
      final taux = await sourceTauxChange.obtenirTaux(deviseSource);
      return Right(taux);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération des taux: $e'));
    }
  }

  Future<Either<Echec, double>> obtenirTauxConversion({
    required String deviseSource,
    required String deviseCible,
  }) async {
    try {
      final taux = await sourceTauxChange.obtenirTauxConversion(
        deviseSource,
        deviseCible,
      );
      return Right(taux);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération du taux: $e'));
    }
  }
}
