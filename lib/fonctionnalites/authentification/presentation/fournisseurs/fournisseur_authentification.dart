import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/services/service_preferences.dart';
import '../../domaine/cas_utilisation/obtenir_utilisateur_actuel.dart';
import '../../domaine/cas_utilisation/s_inscrire.dart';
import '../../domaine/cas_utilisation/se_connecter.dart';
import '../../domaine/cas_utilisation/se_deconnecter.dart';
import '../../domaine/cas_utilisation/authentifier_biometrie.dart';
import '../../donnees/sources_donnees/source_biometrie.dart';
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

  bool _biometrieDisponible = false;
  bool get biometrieDisponible => _biometrieDisponible;

  bool _biometrieActivee = false;
  bool get biometrieActivee => _biometrieActivee;
  set biometrieActivee(bool valeur) {
    _biometrieActivee = valeur;
    notifyListeners();
  }

  List<BiometricType> _typesBiometrie = [];
  List<BiometricType> get typesBiometrie => _typesBiometrie;

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

  Future<void> verifierBiometrieDisponible() async {
    final sourceBiometrie = SourceBiometrieImpl();
    final authentifierBiometrie = AuthentifierBiometrie(sourceBiometrie);
    final resultat = await authentifierBiometrie.verifierDisponibilite();
    
    resultat.fold(
      (echec) => _biometrieDisponible = false,
      (disponible) => _biometrieDisponible = disponible,
    );

    // Récupérer les types de biométrie disponibles
    final resultatTypes = await authentifierBiometrie.obtenirTypesDisponibles();
    resultatTypes.fold(
      (echec) => _typesBiometrie = [],
      (types) => _typesBiometrie = types,
    );

    notifyListeners();
  }

  Future<bool> authentifierBiometrie() async {
    final sourceBiometrie = SourceBiometrieImpl();
    final authentifierBiometrie = AuthentifierBiometrie(sourceBiometrie);
    final resultat = await authentifierBiometrie.executer();
    
    return resultat.fold(
      (echec) {
        _definirErreur(echec.message);
        return false;
      },
      (succes) => succes,
    );
  }

  Future<void> sauvegarderBiometrieActivee() async {
    final servicePreferences = ServicePreferences();
    await servicePreferences.sauvegarderBiometrieActivee(_biometrieActivee);
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
