import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_transaction.dart';

/// Paramètres pour la vérification du solde avant une dépense
class ParametresVerificationSolde extends Equatable {
  final double montant;

  const ParametresVerificationSolde({required this.montant});

  @override
  List<Object> get props => [montant];
}

/// Cas d'utilisation pour vérifier si le solde est suffisant pour une dépense
/// Retourne true si le solde est suffisant, false sinon
class VerifierSolde implements CasUtilisation<bool, ParametresVerificationSolde> {
  final DepotTransaction depot;

  VerifierSolde(this.depot);

  @override
  Future<Either<Echec, bool>> call(ParametresVerificationSolde params) async {
    final result = await depot.obtenirTransactions();
    
    return result.fold(
      (echec) => Left(echec),
      (transactions) {
        // Calcul du solde actuel
        double solde = 0.0;
        for (var t in transactions) {
          if (t.type == 'income') {
            solde += t.amount;
          } else {
            solde -= t.amount;
          }
        }
        
        // Vérification si le solde est suffisant
        final suffisant = params.montant <= solde;
        return Right(suffisant);
      },
    );
  }
}
