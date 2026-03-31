import 'package:flutter/material.dart';
import '../../domaine/cas_utilisation/analyser_depenses.dart';
import '../../domaine/entites/conseil_ia.dart';

// ─────────────────────────────────────────────
// Fournisseur Analyse IA - Présentation
// ─────────────────────────────────────────────
class FournisseurAnalyseIA extends ChangeNotifier {
  final AnalyserDepenses casAnalyser;

  FournisseurAnalyseIA({required this.casAnalyser});

  List<ConseilIA> _conseils = [];
  List<ConseilIA> get conseils => _conseils;

  bool _enChargement = false;
  bool get enChargement => _enChargement;

  String? _messageErreur;
  String? get messageErreur => _messageErreur;

  DateTime? _derniereAnalyse;
  DateTime? get derniereAnalyse => _derniereAnalyse;

  Future<void> analyser(String utilisateurId) async {
    if (_enChargement) return;

    _enChargement = true;
    _messageErreur = null;
    notifyListeners();

    final resultat = await casAnalyser(ParametresAnalyse(utilisateurId));

    resultat.fold(
      (echec) {
        _messageErreur = echec.message;
        _conseils = [];
      },
      (conseils) {
        _conseils = conseils;
        _derniereAnalyse = DateTime.now();
        _messageErreur = null;
      },
    );

    _enChargement = false;
    notifyListeners();
  }

  void reinitialiser() {
    _conseils = [];
    _enChargement = false;
    _messageErreur = null;
    _derniereAnalyse = null;
    notifyListeners();
  }
}
