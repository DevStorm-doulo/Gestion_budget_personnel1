import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../domaine/depots/depot_conversion.dart';
import '../../domaine/entites/conversion.dart';
import '../../domaine/entites/devise.dart';
import '../sources_donnees/source_taux_change.dart';

// ─────────────────────────────────────────────
// Implémentation du dépôt Conversion - Données
// ─────────────────────────────────────────────
class DepotConversionImpl implements DepotConversion {
  final SourceTauxChange _sourceTauxChange;
  final String _cleHistorique = 'historique_conversions';

  DepotConversionImpl({required SourceTauxChange sourceTauxChange})
      : _sourceTauxChange = sourceTauxChange;

  @override
  Future<Either<Echec, Conversion>> convertir({
    required double montant,
    required Devise deviseSource,
    required Devise deviseCible,
  }) async {
    try {
      final taux = await _sourceTauxChange.obtenirTauxConversion(
        deviseSource.code,
        deviseCible.code,
      );

      final montantCible = montant * taux;
      final conversion = Conversion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        montantSource: montant,
        montantCible: montantCible,
        deviseSource: deviseSource,
        deviseCible: deviseCible,
        tauxChange: taux,
        dateConversion: DateTime.now(),
      );

      // Sauvegarder dans l'historique
      await sauvegarderConversion(conversion);

      return Right(conversion);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la conversion: $e'));
    }
  }

  @override
  Future<Either<Echec, List<Conversion>>> obtenirHistorique() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiqueJson = prefs.getStringList(_cleHistorique) ?? [];

      final historique = historiqueJson
          .map((json) => Conversion.fromMap(jsonDecode(json)))
          .toList();

      // Trier par date (plus récent en premier)
      historique.sort((a, b) => b.dateConversion.compareTo(a.dateConversion));

      return Right(historique);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la récupération de l\'historique: $e'));
    }
  }

  @override
  Future<Either<Echec, void>> sauvegarderConversion(Conversion conversion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiqueJson = prefs.getStringList(_cleHistorique) ?? [];

      // Ajouter la nouvelle conversion
      historiqueJson.add(jsonEncode(conversion.toMap()));

      // Limiter à 50 conversions
      if (historiqueJson.length > 50) {
        historiqueJson.removeAt(0);
      }

      await prefs.setStringList(_cleHistorique, historiqueJson);

      return const Right(null);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la sauvegarde: $e'));
    }
  }

  @override
  Future<Either<Echec, void>> supprimerConversion(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiqueJson = prefs.getStringList(_cleHistorique) ?? [];

      historiqueJson.removeWhere((json) {
        final conversion = Conversion.fromMap(jsonDecode(json));
        return conversion.id == id;
      });

      await prefs.setStringList(_cleHistorique, historiqueJson);

      return const Right(null);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la suppression: $e'));
    }
  }

  @override
  Future<Either<Echec, void>> supprimerHistorique() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cleHistorique);

      return const Right(null);
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la suppression de l\'historique: $e'));
    }
  }
}
