import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../modeles/utilisateur_modele.dart';

abstract class SourceAuthentificationFirebase {
  Future<UtilisateurModele> seConnecter(String email, String motDePasse);
  Future<UtilisateurModele> sInscrire(String email, String motDePasse, String nomAffichage);
  Future<void> seDeconnecter();
  Future<UtilisateurModele?> obtenirUtilisateurActuel();
}

class SourceAuthentificationFirebaseImpl implements SourceAuthentificationFirebase {
  final FirebaseAuth firebaseAuth;

  SourceAuthentificationFirebaseImpl(this.firebaseAuth);

  @override
  Future<UtilisateurModele> seConnecter(String email, String motDePasse) async {
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      if (credentials.user != null) {
        return UtilisateurModele.depuisFirebase(credentials.user!);
      } else {
        throw ExceptionAuthentification('Utilisateur non trouvé après connexion.');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur de connexion Firebase.';
      if (e.code == 'user-not-found' || 
          e.code == 'wrong-password' || 
          e.code == 'invalid-credential') {
        message = 'Email ou mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        message = 'Format d\'email invalide.';
      } else if (e.code == 'user-disabled') {
        message = 'Ce compte a été désactivé.';
      } else {
        message = 'Erreur: ${e.code} - ${e.message}';
      }
      throw ExceptionAuthentification(message);
    } catch (e) {
      throw ExceptionServeur(e.toString());
    }
  }

  @override
  Future<UtilisateurModele> sInscrire(String email, String motDePasse, String nomAffichage) async {
    try {
      final credentials = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      
      if (credentials.user != null) {
        try {
          await credentials.user!.updateDisplayName(nomAffichage);
          await credentials.user!.reload();
        } catch (e) {
          // Ignorer l'erreur de mise à jour du profil, l'utilisateur est quand même créé
        }
        final utilisateurMisAJour = firebaseAuth.currentUser;
        return UtilisateurModele.depuisFirebase(utilisateurMisAJour!);
      } else {
        throw ExceptionAuthentification('Erreur lors de la création de l\'utilisateur.');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur d\'inscription Firebase.';
      if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé par un autre compte.';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else if (e.code == 'invalid-email') {
        message = 'Format d\'email invalide.';
      } else if (e.code == 'operation-not-allowed' || e.code == 'configuration-not-found') {
        message = 'L\'authentification par email/mot de passe n\'est pas activée dans Firebase.';
      } else {
        message = 'Erreur: ${e.code} - ${e.message}';
      }
      throw ExceptionAuthentification(message);
    } catch (e) {
      throw ExceptionServeur(e.toString());
    }
  }

  @override
  Future<void> seDeconnecter() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ExceptionServeur('Erreur lors de la déconnexion.');
    }
  }

  @override
  Future<UtilisateurModele?> obtenirUtilisateurActuel() async {
    try {
      final utilisateurActuel = firebaseAuth.currentUser;
      if (utilisateurActuel != null) {
        return UtilisateurModele.depuisFirebase(utilisateurActuel);
      }
      return null;
    } catch (e) {
      throw ExceptionServeur('Erreur lors de la récupération de l\'utilisateur.');
    }
  }
}
