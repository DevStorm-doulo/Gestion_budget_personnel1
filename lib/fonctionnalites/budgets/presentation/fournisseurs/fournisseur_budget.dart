import 'package:flutter/material.dart';
import '../../domaine/entites/budget.dart';
import '../../domaine/cas_utilisation/obtenir_budgets.dart';
import '../../domaine/cas_utilisation/ajouter_budget.dart';
import '../../domaine/cas_utilisation/modifier_budget.dart';
import '../../domaine/cas_utilisation/supprimer_budget.dart';

// ─────────────────────────────────────────────
// Fournisseur (Provider) pour les budgets
// ─────────────────────────────────────────────
class FournisseurBudget extends ChangeNotifier {
  final ObtenirBudgets casObtenirBudgets;
  final AjouterBudget casAjouterBudget;
  final ModifierBudget casModifierBudget;
  final SupprimerBudget casSupprimerBudget;
  
  FournisseurBudget({
    required this.casObtenirBudgets,
    required this.casAjouterBudget,
    required this.casModifierBudget,
    required this.casSupprimerBudget,
  });
  
  // État
  List<Budget> _budgets = [];
  bool _enChargement = false;
  String? _messageErreur;
  int _moisSelectionne = DateTime.now().month;
  int _anneeSelectionnee = DateTime.now().year;
  String? _utilisateurId;
  
  // Getters
  List<Budget> get budgets => _budgets;
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;
  int get moisSelectionne => _moisSelectionne;
  int get anneeSelectionnee => _anneeSelectionnee;
  
  /// Retourne les budgets en alerte (> 80% consommé)
  List<Budget> get budgetsEnAlerte =>
      _budgets.where((b) => b.estEnAlerte || b.estDepasse).toList();
  
  /// Retourne le total des limites de budget
  double get totalLimites =>
      _budgets.fold(0.0, (sum, b) => sum + b.montantLimite);
  
  /// Retourne le total des montants dépensés
  double get totalDepenses =>
      _budgets.fold(0.0, (sum, b) => sum + b.montantDepense);
  
  /// Retourne le pourcentage global de consommation
  double get pourcentageGlobal {
    if (totalLimites <= 0) return 0;
    return (totalDepenses / totalLimites).clamp(0.0, 1.0);
  }
  
  /// Initialise le fournisseur avec l'ID utilisateur
  void initialiser(String utilisateurId) {
    _utilisateurId = utilisateurId;
  }
  
  /// Change le mois/année sélectionné
  void changerPeriode(int mois, int annee) {
    _moisSelectionne = mois;
    _anneeSelectionnee = annee;
    if (_utilisateurId != null) {
      chargerBudgets(_utilisateurId!);
    }
  }
  
  /// Charge les budgets pour le mois/année sélectionné
  Future<void> chargerBudgets(String utilisateurId) async {
    _utilisateurId = utilisateurId;
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();
    
    final resultat = await casObtenirBudgets(
      ParametresObtenirBudgets(
        utilisateurId: utilisateurId,
        mois: _moisSelectionne,
        annee: _anneeSelectionnee,
      ),
    );
    
    resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _enChargement = false;
        notifyListeners();
      },
      (budgets) {
        _budgets = budgets;
        _enChargement = false;
        notifyListeners();
      },
    );
  }
  
  /// Ajoute un nouveau budget
  Future<bool> ajouterBudget(String utilisateurId, Budget budget) async {
    _enChargement = true;
    notifyListeners();
    
    final resultat = await casAjouterBudget(
      ParametresAjouterBudget(
        utilisateurId: utilisateurId,
        budget: budget,
      ),
    );
    
    return resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _enChargement = false;
        notifyListeners();
        return false;
      },
      (budgetAjoute) {
        _budgets.add(budgetAjoute);
        _enChargement = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// Modifie un budget existant
  Future<bool> modifierBudget(String utilisateurId, Budget budget) async {
    _enChargement = true;
    notifyListeners();
    
    final resultat = await casModifierBudget(
      ParametresModifierBudget(
        utilisateurId: utilisateurId,
        budget: budget,
      ),
    );
    
    return resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _enChargement = false;
        notifyListeners();
        return false;
      },
      (budgetModifie) {
        final index = _budgets.indexWhere((b) => b.id == budgetModifie.id);
        if (index != -1) {
          _budgets[index] = budgetModifie;
        }
        _enChargement = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// Supprime un budget
  Future<bool> supprimerBudget(String utilisateurId, String budgetId) async {
    _enChargement = true;
    notifyListeners();
    
    final resultat = await casSupprimerBudget(
      ParametresSupprimerBudget(
        utilisateurId: utilisateurId,
        budgetId: budgetId,
      ),
    );
    
    return resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _enChargement = false;
        notifyListeners();
        return false;
      },
      (_) {
        _budgets.removeWhere((b) => b.id == budgetId);
        _enChargement = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  /// Met à jour le montant dépensé d'un budget
  void mettreAJourMontantDepense(String budgetId, double montantDepense) {
    final index = _budgets.indexWhere((b) => b.id == budgetId);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(montantDepense: montantDepense);
      notifyListeners();
    }
  }
  
  /// Efface le message d'erreur
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}
