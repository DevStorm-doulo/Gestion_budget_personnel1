import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_conversion.dart';
import '../entites/conversion.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Obtenir l'historique des conversions
// ─────────────────────────────────────────────
class ObtenirHistoriqueConversions {
  final DepotConversion depot;

  ObtenirHistoriqueConversions(this.depot);

  Future<Either<Echec, List<Conversion>>> executer() async {
    return await depot.obtenirHistorique();
  }
}
