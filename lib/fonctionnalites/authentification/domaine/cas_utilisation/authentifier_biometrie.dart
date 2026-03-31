import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../donnees/sources_donnees/source_biometrie.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Authentification biométrique
// ─────────────────────────────────────────────
class AuthentifierBiometrie {
  final SourceBiometrieImpl sourceBiometrie;

  AuthentifierBiometrie(this.sourceBiometrie);

  /// Exécute l'authentification biométrique
  Future<Either<Echec, bool>> executer() async {
    try {
      final resultat = await sourceBiometrie.authentifier();
      return Right(resultat);
    } on ExceptionBiometrie catch (e) {
      return Left(EchecServeur(e.message));
    } catch (e) {
      return Left(EchecServeur('Erreur lors de l\'authentification biométrique: $e'));
    }
  }

  /// Vérifie si la biométrie est disponible
  Future<Either<Echec, bool>> verifierDisponibilite() async {
    try {
      final disponible = await sourceBiometrie.estDisponible();
      return Right(disponible);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la vérification de la biométrie: $e'));
    }
  }

  /// Retourne les types de biométrie disponibles
  Future<Either<Echec, List<BiometricType>>> obtenirTypesDisponibles() async {
    try {
      final types = await sourceBiometrie.obtenirTypesDisponibles();
      return Right(types);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération des types de biométrie: $e'));
    }
  }
}
