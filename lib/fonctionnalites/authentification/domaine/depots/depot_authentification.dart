import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/utilisateur.dart';

abstract class DepotAuthentification {
  Future<Either<Echec, Utilisateur>> seConnecter(String email, String motDePasse);
  Future<Either<Echec, Utilisateur>> sInscrire(String email, String motDePasse, String nomAffichage);
  Future<Either<Echec, void>> seDeconnecter();
  Future<Either<Echec, Utilisateur?>> obtenirUtilisateurActuel();
}
