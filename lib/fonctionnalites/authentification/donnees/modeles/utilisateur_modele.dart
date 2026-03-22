import '../../domaine/entites/utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UtilisateurModele extends Utilisateur {
  const UtilisateurModele({
    required super.id,
    required super.email,
    required super.nomAffichage,
  });

  factory UtilisateurModele.depuisFirebase(firebase_auth.User utilisateurFirebase) {
    return UtilisateurModele(
      id: utilisateurFirebase.uid,
      email: utilisateurFirebase.email ?? '',
      nomAffichage: utilisateurFirebase.displayName ?? 'Utilisateur',
    );
  }
}
