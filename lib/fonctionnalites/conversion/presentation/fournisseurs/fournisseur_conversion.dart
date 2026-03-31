import 'package:flutter/material.dart';
import '../../domaine/cas_utilisation/convertir_montant.dart';
import '../../domaine/cas_utilisation/obtenir_taux_change.dart';
import '../../domaine/cas_utilisation/obtenir_historique_conversions.dart';
import '../../domaine/entites/conversion.dart';
import '../../domaine/entites/devise.dart';

// ─────────────────────────────────────────────
// Fournisseur de conversion - Présentation
// ─────────────────────────────────────────────
class FournisseurConversion extends ChangeNotifier {
  final ConvertirMontant _convertirMontant;
  final ObtenirTauxChange _obtenirTauxChange;
  final ObtenirHistoriqueConversions _obtenirHistoriqueConversions;

  FournisseurConversion({
    required ConvertirMontant convertirMontant,
    required ObtenirTauxChange obtenirTauxChange,
    required ObtenirHistoriqueConversions obtenirHistoriqueConversions,
  })  : _convertirMontant = convertirMontant,
        _obtenirTauxChange = obtenirTauxChange,
        _obtenirHistoriqueConversions = obtenirHistoriqueConversions;

  // État
  bool _enChargement = false;
  String? _messageErreur;
  Conversion? _derniereConversion;
  List<Conversion> _historique = [];
  Devise _deviseSource = Devise.devises[0]; // FCFA par défaut
  Devise _deviseCible = Devise.devises[1]; // USD par défaut
  double _tauxActuel = 0.0;

  // Getters
  bool get enChargement => _enChargement;
  String? get messageErreur => _messageErreur;
  Conversion? get derniereConversion => _derniereConversion;
  List<Conversion> get historique => _historique;
  Devise get deviseSource => _deviseSource;
  Devise get deviseCible => _deviseCible;
  double get tauxActuel => _tauxActuel;

  /// Convertit un montant
  Future<void> convertir(double montant) async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    final resultat = await _convertirMontant.executer(
      montant: montant,
      deviseSource: _deviseSource,
      deviseCible: _deviseCible,
    );

    resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _derniereConversion = null;
      },
      (conversion) {
        _derniereConversion = conversion;
        _messageErreur = null;
        // Recharger l'historique
        chargerHistorique();
      },
    );

    _enChargement = false;
    notifyListeners();
  }

  /// Change la devise source
  void changerDeviseSource(Devise devise) {
    if (devise.code != _deviseCible.code) {
      _deviseSource = devise;
      _mettreAJourTaux();
      notifyListeners();
    }
  }

  /// Change la devise cible
  void changerDeviseCible(Devise devise) {
    if (devise.code != _deviseSource.code) {
      _deviseCible = devise;
      _mettreAJourTaux();
      notifyListeners();
    }
  }

  /// Inverse les devises source et cible
  void inverserDevises() {
    final temp = _deviseSource;
    _deviseSource = _deviseCible;
    _deviseCible = temp;
    _mettreAJourTaux();
    notifyListeners();
  }

  /// Met à jour le taux de change
  Future<void> _mettreAJourTaux() async {
    final resultat = await _obtenirTauxChange.obtenirTauxConversion(
      deviseSource: _deviseSource.code,
      deviseCible: _deviseCible.code,
    );

    resultat.fold(
      (echec) => _tauxActuel = 0.0,
      (taux) => _tauxActuel = taux,
    );
  }

  /// Charge l'historique des conversions
  Future<void> chargerHistorique() async {
    final resultat = await _obtenirHistoriqueConversions.executer();

    resultat.fold(
      (echec) => _messageErreur = echec.message,
      (historique) => _historique = historique,
    );

    notifyListeners();
  }

  /// Efface le message d'erreur
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }

  /// Initialise le fournisseur
  Future<void> initialiser() async {
    await _mettreAJourTaux();
    await chargerHistorique();
  }
}
