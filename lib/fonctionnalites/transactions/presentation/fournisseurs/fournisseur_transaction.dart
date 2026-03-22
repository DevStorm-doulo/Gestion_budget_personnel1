import 'package:flutter/material.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../domaine/cas_utilisation/ajouter_transaction.dart';
import '../../domaine/cas_utilisation/obtenir_transactions.dart';
import '../../domaine/cas_utilisation/modifier_transaction.dart';
import '../../domaine/cas_utilisation/supprimer_transaction.dart';
import '../../domaine/entites/transaction.dart';

class FournisseurTransaction extends ChangeNotifier {
  final AjouterTransaction casAjouter;
  final ObtenirTransactions casObtenir;
  final ModifierTransaction casModifier;
  final SupprimerTransaction casSupprimer;

  FournisseurTransaction({
    required this.casAjouter,
    required this.casObtenir,
    required this.casModifier,
    required this.casSupprimer,
  });

  List<TransactionEntity> _transactions = [];
  List<TransactionEntity> get transactions => _transactions;

  // Ensemble des transactions masquées
  final Set<String> _transactionsMasquees = {};
  List<TransactionEntity> get transactionsVisibles => 
      _transactions.where((t) => !_transactionsMasquees.contains(t.id)).toList();

  bool _enChargement = false;
  bool get enChargement => _enChargement;

  String? _messageErreur;
  String? get messageErreur => _messageErreur;

  Future<void> chargerTransactions() async {
    _definirChargement(true);
    final resultat = await casObtenir(SansParametres());

    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (liste) {
        _transactions = liste;
        _definirErreur(null);
      },
    );
    _definirChargement(false);
  }

  Future<bool> ajouterTransaction(TransactionEntity transaction) async {
    _definirChargement(true);
    debugPrint('Ajout transaction: ${transaction.amount} ${transaction.category}');
    try {
      final resultat = await casAjouter(ParametresTransaction(transaction));

      bool succes = false;
      resultat.fold(
        (echec) {
          debugPrint('Erreur ajout: ${echec.message}');
          _definirErreur(echec.message);
        },
        (_) {
          debugPrint('Succès ajout transaction');
          succes = true;
          _definirErreur(null);
        },
      );

      if (succes) await chargerTransactions();
      _definirChargement(false);
      return succes;
    } catch (e) {
      debugPrint('Exception non gérée: $e');
      _definirErreur(e.toString());
      _definirChargement(false);
      return false;
    }
  }

  Future<bool> modifierTransaction(TransactionEntity transaction) async {
    _definirChargement(true);
    final resultat = await casModifier(ParametresTransaction(transaction));

    bool succes = false;
    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (_) {
        succes = true;
        _definirErreur(null);
      },
    );

    if (succes) await chargerTransactions();
    _definirChargement(false);
    return succes;
  }

  Future<bool> supprimerTransaction(String id) async {
    _definirChargement(true);
    final resultat = await casSupprimer(ParametresSuppression(id));

    bool succes = false;
    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (_) {
        succes = true;
        _definirErreur(null);
      },
    );

    if (succes) await chargerTransactions();
    _definirChargement(false);
    return succes;
  }

  // Masquer une transaction (sans la supprimer de la base de données)
  void masquerTransaction(String id) {
    _transactionsMasquees.add(id);
    notifyListeners();
  }

  // Réafficher une transaction masquée
  void afficherTransaction(String id) {
    _transactionsMasquees.remove(id);
    notifyListeners();
  }

  // Réinitialiser les transactions masquées
  void reinitialiserMasquer() {
    _transactionsMasquees.clear();
    notifyListeners();
  }

  void _definirChargement(bool valeur) {
    _enChargement = valeur;
    notifyListeners();
  }

  void _definirErreur(String? message) {
    _messageErreur = message;
    notifyListeners();
  }
}
