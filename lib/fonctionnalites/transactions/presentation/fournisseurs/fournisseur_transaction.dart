import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../domaine/cas_utilisation/ajouter_transaction.dart';
import '../../domaine/cas_utilisation/obtenir_transactions.dart';
import '../../domaine/cas_utilisation/modifier_transaction.dart';
import '../../domaine/cas_utilisation/supprimer_transaction.dart';
import '../../domaine/cas_utilisation/verifier_solde.dart';
import '../../domaine/cas_utilisation/scanner_recu.dart';
import '../../domaine/entites/transaction.dart';
import '../../domaine/entites/resultat_scan.dart';

class FournisseurTransaction extends ChangeNotifier {
  final AjouterTransaction casAjouter;
  final ObtenirTransactions casObtenir;
  final ModifierTransaction casModifier;
  final SupprimerTransaction casSupprimer;
  final VerifierSolde casVerifierSolde;
  final ScannerRecu casScannerRecu;

  FournisseurTransaction({
    required this.casAjouter,
    required this.casObtenir,
    required this.casModifier,
    required this.casSupprimer,
    required this.casVerifierSolde,
    required this.casScannerRecu,
  });

  List<TransactionEntity> _transactions = [];
  List<TransactionEntity> get transactions => _transactions;

  // Ensemble des transactions masquées
  final Set<String> _transactionsMasquees = {};
  List<TransactionEntity> get transactionsVisibles => 
      _transactions.where((t) => !_transactionsMasquees.contains(t.id)).toList();

  // Instance SharedPreferences pour la persistance
  SharedPreferences? _preferences;

  // Clé pour stocker les IDs masqués
  static const String _clesTransactionsMasquees = 'transactions_masques';

  bool _enChargement = false;
  bool get enChargement => _enChargement;

  String? _messageErreur;
  String? get messageErreur => _messageErreur;

  // Propriétés pour le scan de reçus
  ResultatScan? _dernierScan;
  ResultatScan? get dernierScan => _dernierScan;

  bool _enCoursAnalyse = false;
  bool get enCoursAnalyse => _enCoursAnalyse;

  String? _messageErreurScan;
  String? get messageErreurScan => _messageErreurScan;

  /// Initialise SharedPreferences et charge les transactions masquées
  Future<void> initialiser() async {
    _preferences = await SharedPreferences.getInstance();
    await _chargerTransactionsMasquees();
  }

  /// Charge les IDs masqués depuis SharedPreferences
  Future<void> _chargerTransactionsMasquees() async {
    if (_preferences == null) return;
    final listeIds = _preferences!.getStringList(_clesTransactionsMasquees) ?? [];
    _transactionsMasquees.clear();
    _transactionsMasquees.addAll(listeIds);
    notifyListeners();
  }

  /// Sauvegarde les IDs masqués dans SharedPreferences
  Future<void> _sauvegarderTransactionsMasquees() async {
    if (_preferences == null) return;
    await _preferences!.setStringList(
      _clesTransactionsMasquees,
      _transactionsMasquees.toList(),
    );
  }

  /// Vérifie si le solde est suffisant avant une dépense
  /// Retourne null si la vérification réussit (solde suffisant ou erreur)
  /// Retourne un message d'erreur si le solde est insuffisant
  Future<String?> verifierSoldeAvantDepense(double montant) async {
    final resultat = await casVerifierSolde(ParametresVerificationSolde(montant: montant));
    
    return resultat.fold(
      (echec) => echec.message, // Erreur du cas d'utilisation
      (soldeSuffisant) {
        if (!soldeSuffisant) {
          // Calculer le solde actuel pour le message
          double solde = 0.0;
          for (var t in _transactions) {
            if (t.type == 'income') {
              solde += t.amount;
            } else {
              solde -= t.amount;
            }
          }
          return 'Solde insuffisant! Votre solde actuel est de ${solde.toStringAsFixed(0)} FCA';
        }
        return null; // Solde suffisant
      },
    );
  }

  /// Vérifie si l'utilisateur a déjà des revenus
  bool get aDesRevenus => _transactions.any((t) => t.type == 'income');

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
  // Sauvegarde automatiquement dans SharedPreferences
  Future<void> masquerTransaction(String id) async {
    _transactionsMasquees.add(id);
    await _sauvegarderTransactionsMasquees();
    notifyListeners();
  }

  // Réafficher une transaction masquée
  // Sauvegarde automatiquement dans SharedPreferences
  Future<void> afficherTransaction(String id) async {
    _transactionsMasquees.remove(id);
    await _sauvegarderTransactionsMasquees();
    notifyListeners();
  }

  // Réinitialiser les transactions masquées
  // Vide également le stockage local
  Future<void> reinitialiserMasquer() async {
    _transactionsMasquees.clear();
    await _sauvegarderTransactionsMasquees();
    notifyListeners();
  }

  // ── Méthodes pour le scan de reçus ──

  /// Analyse un reçu depuis la caméra
  Future<void> analyserRecuDepuisCamera() async {
    _enCoursAnalyse = true;
    _messageErreurScan = null;
    notifyListeners();

    final resultat = await casScannerRecu.executerDepuisCamera();

    resultat.fold(
      (echec) {
        _messageErreurScan = echec.message;
        _dernierScan = null;
      },
      (scan) {
        _dernierScan = scan;
        _messageErreurScan = null;
      },
    );

    _enCoursAnalyse = false;
    notifyListeners();
  }

  /// Analyse un reçu depuis la galerie
  Future<void> analyserRecuDepuisGalerie() async {
    _enCoursAnalyse = true;
    _messageErreurScan = null;
    notifyListeners();

    final resultat = await casScannerRecu.executerDepuisGalerie();

    resultat.fold(
      (echec) {
        _messageErreurScan = echec.message;
        _dernierScan = null;
      },
      (scan) {
        _dernierScan = scan;
        _messageErreurScan = null;
      },
    );

    _enCoursAnalyse = false;
    notifyListeners();
  }

  /// Réinitialise les données du scan
  void reinitialiserScan() {
    _dernierScan = null;
    _messageErreurScan = null;
    _enCoursAnalyse = false;
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
