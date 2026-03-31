import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_conversion.dart';
import '../entites/conversion.dart';
import '../entites/devise.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Convertir un montant
// ─────────────────────────────────────────────
class ConvertirMontant {
  final DepotConversion depot;

  ConvertirMontant(this.depot);

  Future<Either<Echec, Conversion>> executer({
    required double montant,
    required Devise deviseSource,
    required Devise deviseCible,
  }) async {
    // Validation du montant
    if (montant <= 0) {
      return Left(EchecValidation('Le montant doit être supérieur à 0'));
    }

    // Validation des devises
    if (deviseSource.code == deviseCible.code) {
      return Left(EchecValidation('Les devises source et cible doivent être différentes'));
    }

    return await depot.convertir(
      montant: montant,
      deviseSource: deviseSource,
      deviseCible: deviseCible,
    );
  }
}
