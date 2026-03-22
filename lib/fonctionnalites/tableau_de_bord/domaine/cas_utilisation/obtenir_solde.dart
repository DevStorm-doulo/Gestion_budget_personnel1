import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../transactions/domaine/depots/depot_transaction.dart';

class ObtenirSolde implements CasUtilisation<double, SansParametres> {
  final DepotTransaction depot;

  ObtenirSolde(this.depot);

  @override
  Future<Either<Echec, double>> call(SansParametres params) async {
    final result = await depot.obtenirTransactions();
    return result.map((transactions) {
      double solde = 0.0;
      for (var t in transactions) {
        if (t.type == 'income') {
          solde += t.amount;
        } else {
          solde -= t.amount;
        }
      }
      return solde;
    });
  }
}
