import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../../core/services/service_preferences.dart';
import '../../domaine/depots/depot_devise.dart';
import '../../domaine/entites/devise.dart';
import '../sources_donnees/source_taux_change.dart';

// ─────────────────────────────────────────────
// Implémentation du dépôt Devise - Données
// ─────────────────────────────────────────────
class DepotDeviseImpl implements DepotDevise {
  final SourceTauxChangeImpl sourceTauxChange;
  final ServicePreferences servicePreferences;

  DepotDeviseImpl({
    required this.sourceTauxChange,
    required this.servicePreferences,
  });

  @override
  Future<Either<Echec, List<Devise>>> obtenirDevises() async {
    try {
      final taux = await sourceTauxChange.obtenirTaux();
      
      final devises = Devise.devisesSupportees.map((devise) {
        if (devise.code == 'XOF') {
          return devise;
        }
        
        final tauxApi = taux[devise.code];
        if (tauxApi != null) {
          return Devise(
            code: devise.code,
            nom: devise.nom,
            symbole: devise.symbole,
            tauxVersXof: tauxApi,
          );
        }
        
        return devise;
      }).toList();

      return Right(devises);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération des devises: $e'));
    }
  }

  @override
  Future<Either<Echec, Devise>> obtenirDeviseActive() async {
    try {
      final codeDevise = servicePreferences.obtenirDeviseActive();
      final devise = Devise.trouverParCode(codeDevise);
      return Right(devise);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération de la devise active: $e'));
    }
  }

  @override
  Future<Either<Echec, void>> changerDevise(String code) async {
    try {
      await servicePreferences.sauvegarderDeviseActive(code);
      return const Right(null);
    } catch (e) {
      return Left(EchecServeur('Erreur lors du changement de devise: $e'));
    }
  }
}
