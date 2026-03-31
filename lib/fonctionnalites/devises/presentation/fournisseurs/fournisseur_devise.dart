import 'package:flutter/material.dart';
import '../../domaine/cas_utilisation/obtenir_devises.dart';
import '../../domaine/cas_utilisation/convertir_montant.dart';
import '../../domaine/entites/devise.dart';
import '../../../../core/utilitaires/formateur_montant.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';

// ─────────────────────────────────────────────
// Fournisseur de devise
// ─────────────────────────────────────────────
class FournisseurDevise extends ChangeNotifier {
  final ObtenirDevises casObtenirDevises;
  final ConvertirMontant casConvertirMontant;

  FournisseurDevise({
    required this.casObtenirDevises,
    required this.casConvertirMontant,
  });

  Devise _deviseActive = Devise.devisesSupportees.first;
  List<Devise> _devises = [];
  bool _enChargement = false;

  Devise get deviseActive => _deviseActive;
  List<Devise> get devises => _devises;
  bool get enChargement => _enChargement;

  /// Initialise le fournisseur de devise
  Future<void> initialiser() async {
    _enChargement = true;
    notifyListeners();

    final resultat = await casObtenirDevises(SansParametres());
    
    resultat.fold(
      (echec) {
        _devises = Devise.devisesSupportees;
      },
      (devises) {
        _devises = devises;
      },
    );

    _enChargement = false;
    notifyListeners();
  }

  /// Change la devise active
  Future<void> changerDevise(Devise devise) async {
    _deviseActive = devise;
    notifyListeners();
  }

  /// Formate un montant selon la devise active
  String formaterMontant(double montant) {
    return FormateurMontant.formater(montant, _deviseActive);
  }
}
