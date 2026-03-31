import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_devise.dart';
import '../entites/devise.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Convertir un montant
// ─────────────────────────────────────────────
class ConvertirMontant implements CasUtilisation<double, ParametresConversion> {
  final DepotDevise depot;

  ConvertirMontant(this.depot);

  @override
  Future<Either<Echec, double>> call(ParametresConversion parametres) async {
    try {
      final resultat = await depot.obtenirDeviseActive();
      
      return resultat.fold(
        (echec) => Left(echec),
        (deviseActive) {
          final montantConverti = parametres.montantXof / deviseActive.tauxVersXof;
          return Right(montantConverti);
        },
      );
    } catch (e) {
      return Left(EchecServeur('Erreur lors de la conversion du montant: $e'));
    }
  }
}

class ParametresConversion {
  final double montantXof;

  const ParametresConversion({
    required this.montantXof,
  });
}
