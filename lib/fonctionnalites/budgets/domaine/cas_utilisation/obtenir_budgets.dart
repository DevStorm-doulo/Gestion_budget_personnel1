import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_budget.dart';
import '../entites/budget.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Obtenir les budgets
// ─────────────────────────────────────────────
class ObtenirBudgets implements CasUtilisation<List<Budget>, ParametresObtenirBudgets> {
  final DepotBudget depot;
  
  ObtenirBudgets(this.depot);
  
  @override
  Future<Either<Echec, List<Budget>>> call(ParametresObtenirBudgets parametres) {
    return depot.obtenirBudgets(
      parametres.utilisateurId,
      parametres.mois,
      parametres.annee,
    );
  }
}

class ParametresObtenirBudgets {
  final String utilisateurId;
  final int mois;
  final int annee;
  
  const ParametresObtenirBudgets({
    required this.utilisateurId,
    required this.mois,
    required this.annee,
  });
}
