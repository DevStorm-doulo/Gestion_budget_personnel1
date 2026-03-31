import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../domaine/depots/depot_budget.dart';
import '../../domaine/entites/budget.dart';
import '../sources_donnees/source_budget_firebase.dart';

// ─────────────────────────────────────────────
// Implémentation du dépôt Budget - Données
// ─────────────────────────────────────────────
class DepotBudgetImpl implements DepotBudget {
  final SourceBudgetFirebaseImpl sourceBdd;
  
  DepotBudgetImpl({required this.sourceBdd});
  
  @override
  Future<Either<Echec, List<Budget>>> obtenirBudgets(
    String utilisateurId,
    int mois,
    int annee,
  ) async {
    try {
      final budgets = await sourceBdd.obtenirBudgets(utilisateurId, mois, annee);
      return Right(budgets);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération des budgets: $e'));
    }
  }
  
  @override
  Future<Either<Echec, Budget>> obtenirBudgetParId(
    String utilisateurId,
    String budgetId,
  ) async {
    try {
      final budget = await sourceBdd.obtenirBudgetParId(utilisateurId, budgetId);
      return Right(budget);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération du budget: $e'));
    }
  }
  
  @override
  Future<Either<Echec, Budget>> ajouterBudget(
    String utilisateurId,
    Budget budget,
  ) async {
    try {
      final budgetAjoute = await sourceBdd.ajouterBudget(utilisateurId, budget);
      return Right(budgetAjoute);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de l\'ajout du budget: $e'));
    }
  }
  
  @override
  Future<Either<Echec, Budget>> modifierBudget(
    String utilisateurId,
    Budget budget,
  ) async {
    try {
      final budgetModifie = await sourceBdd.modifierBudget(utilisateurId, budget);
      return Right(budgetModifie);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la modification du budget: $e'));
    }
  }
  
  @override
  Future<Either<Echec, Unit>> supprimerBudget(
    String utilisateurId,
    String budgetId,
  ) async {
    try {
      await sourceBdd.supprimerBudget(utilisateurId, budgetId);
      return const Right(unit);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la suppression du budget: $e'));
    }
  }
  
  @override
  Future<Either<Echec, Budget>> mettreAJourMontantDepense(
    String utilisateurId,
    String budgetId,
    double montantDepense,
  ) async {
    try {
      final budgetMisAJour = await sourceBdd.mettreAJourMontantDepense(
        utilisateurId,
        budgetId,
        montantDepense,
      );
      return Right(budgetMisAJour);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la mise à jour du montant dépensé: $e'));
    }
  }
  
  @override
  Future<Either<Echec, List<Budget>>> obtenirBudgetsEnAlerte(
    String utilisateurId,
    int mois,
    int annee,
  ) async {
    try {
      final budgets = await sourceBdd.obtenirBudgetsEnAlerte(utilisateurId, mois, annee);
      return Right(budgets);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération des budgets en alerte: $e'));
    }
  }
}
