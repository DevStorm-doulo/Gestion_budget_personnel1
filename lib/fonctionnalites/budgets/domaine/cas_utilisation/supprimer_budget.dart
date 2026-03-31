import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_budget.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Supprimer un budget
// ─────────────────────────────────────────────
class SupprimerBudget implements CasUtilisation<Unit, ParametresSupprimerBudget> {
  final DepotBudget depot;
  
  SupprimerBudget(this.depot);
  
  @override
  Future<Either<Echec, Unit>> call(ParametresSupprimerBudget parametres) {
    return depot.supprimerBudget(
      parametres.utilisateurId,
      parametres.budgetId,
    );
  }
}

class ParametresSupprimerBudget {
  final String utilisateurId;
  final String budgetId;
  
  const ParametresSupprimerBudget({
    required this.utilisateurId,
    required this.budgetId,
  });
}
