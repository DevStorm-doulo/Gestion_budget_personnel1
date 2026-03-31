import 'package:flutter/material.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../domaine/cas_utilisation/obtenir_solde.dart';
import '../../domaine/cas_utilisation/obtenir_statistiques_mensuelles.dart';

class FournisseurTableauBord extends ChangeNotifier {
  final ObtenirSolde casObtenirSolde;
  final ObtenirStatistiquesMensuelles casObtenirStatistiques;

  FournisseurTableauBord({
    required this.casObtenirSolde,
    required this.casObtenirStatistiques,
  });

  double _soldeActuel = 0.0;
  double get soldeActuel => _soldeActuel;

  StatistiquesMensuelles? _statistiques;
  StatistiquesMensuelles? get statistiques => _statistiques;

  bool _enChargement = false;
  bool get enChargement => _enChargement;

  String? _messageErreur;
  String? get messageErreur => _messageErreur;

  Future<void> chargerDonnees() async {
    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    final resultSolde = await casObtenirSolde(SansParametres());
    resultSolde.fold(
      (echec) => _definirErreur(echec.message),
      (solde) => _soldeActuel = solde,
    );

    final resultStats = await casObtenirStatistiques(SansParametres());
    resultStats.fold(
      (echec) => _definirErreur(echec.message),
      (stats) => _statistiques = stats,
    );

    _enChargement = false;
    notifyListeners();
  }

  void _definirErreur(String message) {
    _messageErreur = message;
  }
}
