import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/budget.dart';

// ─────────────────────────────────────────────
// Interface du dépôt Budget - Domaine
// ─────────────────────────────────────────────
abstract class DepotBudget {
  /// Obtient tous les budgets d'un utilisateur pour un mois/année donné
  Future<Either<Echec, List<Budget>>> obtenirBudgets(
    String utilisateurId,
    int mois,
    int annee,
  );
  
  /// Obtient un budget par son ID
  Future<Either<Echec, Budget>> obtenirBudgetParId(
    String utilisateurId,
    String budgetId,
  );
  
  /// Ajoute un nouveau budget
  Future<Either<Echec, Budget>> ajouterBudget(
    String utilisateurId,
    Budget budget,
  );
  
  /// Met à jour un budget existant
  Future<Either<Echec, Budget>> modifierBudget(
    String utilisateurId,
    Budget budget,
  );
  
  /// Supprime un budget
  Future<Either<Echec, Unit>> supprimerBudget(
    String utilisateurId,
    String budgetId,
  );
  
  /// Met à jour le montant dépensé d'un budget
  Future<Either<Echec, Budget>> mettreAJourMontantDepense(
    String utilisateurId,
    String budgetId,
    double montantDepense,
  );
  
  /// Obtient les budgets en alerte (> 80% consommé)
  Future<Either<Echec, List<Budget>>> obtenirBudgetsEnAlerte(
    String utilisateurId,
    int mois,
    int annee,
  );
}
