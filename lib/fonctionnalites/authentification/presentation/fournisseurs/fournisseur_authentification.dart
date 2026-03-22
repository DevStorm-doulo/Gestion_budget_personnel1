import 'package:flutter/material.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../domaine/cas_utilisation/obtenir_utilisateur_actuel.dart';
import '../../domaine/cas_utilisation/s_inscrire.dart';
import '../../domaine/cas_utilisation/se_connecter.dart';
import '../../domaine/cas_utilisation/se_deconnecter.dart';
import '../../domaine/entites/utilisateur.dart';

class FournisseurAuthentification extends ChangeNotifier {
  final SeConnecter casSeConnecter;
  final SInscrire casSInscrire;
  final SeDeconnecter casSeDeconnecter;
  final ObtenirUtilisateurActuel casObtenirUtilisateurActuel;

  FournisseurAuthentification({
    required this.casSeConnecter,
    required this.casSInscrire,
    required this.casSeDeconnecter,
    required this.casObtenirUtilisateurActuel,
  }) {
    verifierSession();
  }

  Utilisateur? _utilisateur;
  Utilisateur? get utilisateur => _utilisateur;

  bool _enChargement = true;
  bool get enChargement => _enChargement;

  String? _messageErreur;
  String? get messageErreur => _messageErreur;

  Future<void> verifierSession() async {
    final resultat = await casObtenirUtilisateurActuel(SansParametres());
    
    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (utilisateurFirebase) {
        _utilisateur = utilisateurFirebase;
        _definirErreur(null);
      },
    );
    _definirChargement(false);
  }

  Future<bool> seConnecter(String email, String motDePasse) async {
    _definirChargement(true);
    final resultat = await casSeConnecter(ParametresConnexion(email: email, motDePasse: motDePasse));
    
    bool succes = false;
    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (utilisateurConnecte) {
        _utilisateur = utilisateurConnecte;
        _definirErreur(null);
        succes = true;
      },
    );
    _definirChargement(false);
    return succes;
  }

  Future<bool> sInscrire(String email, String motDePasse, String nomAffichage) async {
    _definirChargement(true);
    final resultat = await casSInscrire(ParametresInscription(email: email, motDePasse: motDePasse, nomAffichage: nomAffichage));
    
    bool succes = false;
    resultat.fold(
      (echec) => _definirErreur(echec.message),
      (utilisateurInscrit) {
        _utilisateur = utilisateurInscrit;
        _definirErreur(null);
        succes = true;
      },
    );
    _definirChargement(false);
    return succes;
  }

  Future<void> seDeconnecter() async {
    _definirChargement(true);
    await casSeDeconnecter(SansParametres());
    _utilisateur = null;
    _definirErreur(null);
    _definirChargement(false);
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
