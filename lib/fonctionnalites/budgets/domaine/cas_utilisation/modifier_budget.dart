import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_budget.dart';
import '../entites/budget.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Modifier un budget
// ─────────────────────────────────────────────
class ModifierBudget implements CasUtilisation<Budget, ParametresModifierBudget> {
  final DepotBudget depot;
  
  ModifierBudget(this.depot);
  
  @override
  Future<Either<Echec, Budget>> call(ParametresModifierBudget parametres) {
    return depot.modifierBudget(
      parametres.utilisateurId,
      parametres.budget,
    );
  }
}

class ParametresModifierBudget {
  final String utilisateurId;
  final Budget budget;
  
  const ParametresModifierBudget({
    required this.utilisateurId,
    required this.budget,
  });
}
