import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domaine/entites/budget.dart';
import '../modeles/budget_modele.dart';

// ─────────────────────────────────────────────
// Source de données Firebase pour les budgets
// ─────────────────────────────────────────────
class SourceBudgetFirebaseImpl {
  final FirebaseFirestore firestore;
  
  SourceBudgetFirebaseImpl({required this.firestore});
  
  /// Référence à la collection des budgets d'un utilisateur
  CollectionReference _budgetsCollection(String utilisateurId) {
    return firestore
        .collection('users')
        .doc(utilisateurId)
        .collection('budgets');
  }
  
  /// Obtient tous les budgets d'un utilisateur pour un mois/année donné
  Future<List<BudgetModele>> obtenirBudgets(
    String utilisateurId,
    int mois,
    int annee,
  ) async {
    try {
      final snapshot = await _budgetsCollection(utilisateurId)
          .where('mois', isEqualTo: mois)
          .where('annee', isEqualTo: annee)
          .orderBy('nomCategorie')
          .get();
      
      return snapshot.docs
          .map((doc) => BudgetModele.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets: $e');
    }
  }
  
  /// Obtient un budget par son ID
  Future<BudgetModele> obtenirBudgetParId(
    String utilisateurId,
    String budgetId,
  ) async {
    try {
      final doc = await _budgetsCollection(utilisateurId).doc(budgetId).get();
      
      if (!doc.exists) {
        throw Exception('Budget non trouvé');
      }
      
      return BudgetModele.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du budget: $e');
    }
  }
  
  /// Ajoute un nouveau budget
  Future<BudgetModele> ajouterBudget(
    String utilisateurId,
    Budget budget,
  ) async {
    try {
      final budgetModele = BudgetModele(
        id: '',
        categorieId: budget.categorieId,
        nomCategorie: budget.nomCategorie,
        montantLimite: budget.montantLimite,
        montantDepense: budget.montantDepense,
        mois: budget.mois,
        annee: budget.annee,
        dateCreation: budget.dateCreation,
        dateModification: budget.dateModification,
      );
      
      final docRef = await _budgetsCollection(utilisateurId)
          .add(budgetModele.toFirestore());
      
      return budgetModele.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du budget: $e');
    }
  }
  
  /// Met à jour un budget existant
  Future<BudgetModele> modifierBudget(
    String utilisateurId,
    Budget budget,
  ) async {
    try {
      final budgetModele = BudgetModele(
        id: budget.id,
        categorieId: budget.categorieId,
        nomCategorie: budget.nomCategorie,
        montantLimite: budget.montantLimite,
        montantDepense: budget.montantDepense,
        mois: budget.mois,
        annee: budget.annee,
        dateCreation: budget.dateCreation,
        dateModification: DateTime.now(),
      );
      
      await _budgetsCollection(utilisateurId)
          .doc(budget.id)
          .update(budgetModele.toFirestore());
      
      return budgetModele;
    } catch (e) {
      throw Exception('Erreur lors de la modification du budget: $e');
    }
  }
  
  /// Supprime un budget
  Future<void> supprimerBudget(
    String utilisateurId,
    String budgetId,
  ) async {
    try {
      await _budgetsCollection(utilisateurId).doc(budgetId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du budget: $e');
    }
  }
  
  /// Met à jour le montant dépensé d'un budget
  Future<BudgetModele> mettreAJourMontantDepense(
    String utilisateurId,
    String budgetId,
    double montantDepense,
  ) async {
    try {
      await _budgetsCollection(utilisateurId).doc(budgetId).update({
        'montantDepense': montantDepense,
        'dateModification': Timestamp.fromDate(DateTime.now()),
      });
      
      return await obtenirBudgetParId(utilisateurId, budgetId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du montant dépensé: $e');
    }
  }
  
  /// Obtient les budgets en alerte (> 80% consommé)
  Future<List<BudgetModele>> obtenirBudgetsEnAlerte(
    String utilisateurId,
    int mois,
    int annee,
  ) async {
    try {
      final budgets = await obtenirBudgets(utilisateurId, mois, annee);
      return budgets.where((budget) => budget.estEnAlerte || budget.estDepasse).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets en alerte: $e');
    }
  }
}
