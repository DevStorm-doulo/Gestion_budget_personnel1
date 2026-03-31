import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_devise.dart';
import '../entites/devise.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Obtenir les devises
// ─────────────────────────────────────────────
class ObtenirDevises implements CasUtilisation<List<Devise>, SansParametres> {
  final DepotDevise depot;

  ObtenirDevises(this.depot);

  @override
  Future<Either<Echec, List<Devise>>> call(SansParametres parametres) {
    return depot.obtenirDevises();
  }
}
