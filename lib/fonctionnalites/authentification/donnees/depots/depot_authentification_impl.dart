import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/depots/depot_authentification.dart';
import '../../domaine/entites/utilisateur.dart';
import '../sources_donnees/source_authentification_firebase.dart';

class DepotAuthentificationImpl implements DepotAuthentification {
  final SourceAuthentificationFirebase sourceBdd;

  DepotAuthentificationImpl({required this.sourceBdd});

  @override
  Future<Either<Echec, Utilisateur>> seConnecter(String email, String motDePasse) async {
    try {
      final utilisateur = await sourceBdd.seConnecter(email, motDePasse);
      return Right(utilisateur);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, Utilisateur>> sInscrire(String email, String motDePasse, String nomAffichage) async {
    try {
      final utilisateur = await sourceBdd.sInscrire(email, motDePasse, nomAffichage);
      return Right(utilisateur);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, void>> seDeconnecter() async {
    try {
      await sourceBdd.seDeconnecter();
      return const Right(null);
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, Utilisateur?>> obtenirUtilisateurActuel() async {
    try {
      final utilisateur = await sourceBdd.obtenirUtilisateurActuel();
      return Right(utilisateur);
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }
}
