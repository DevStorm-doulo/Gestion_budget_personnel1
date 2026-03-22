import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_transaction.dart';
import '../entites/transaction.dart';

class ObtenirTransactions implements CasUtilisation<List<TransactionEntity>, SansParametres> {
  final DepotTransaction depot;

  ObtenirTransactions(this.depot);

  @override
  Future<Either<Echec, List<TransactionEntity>>> call(SansParametres params) async {
    return await depot.obtenirTransactions();
  }
}
