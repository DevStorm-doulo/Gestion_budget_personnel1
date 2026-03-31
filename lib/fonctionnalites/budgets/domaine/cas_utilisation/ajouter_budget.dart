import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_budget.dart';
import '../entites/budget.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Ajouter un budget
// ─────────────────────────────────────────────
class AjouterBudget implements CasUtilisation<Budget, ParametresAjouterBudget> {
  final DepotBudget depot;
  
  AjouterBudget(this.depot);
  
  @override
  Future<Either<Echec, Budget>> call(ParametresAjouterBudget parametres) {
    return depot.ajouterBudget(
      parametres.utilisateurId,
      parametres.budget,
    );
  }
}

class ParametresAjouterBudget {
  final String utilisateurId;
  final Budget budget;
  
  const ParametresAjouterBudget({
    required this.utilisateurId,
    required this.budget,
  });
}
