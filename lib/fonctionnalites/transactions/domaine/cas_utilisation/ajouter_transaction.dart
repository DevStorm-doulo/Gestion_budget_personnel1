import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_transaction.dart';
import '../entites/transaction.dart';
import 'package:equatable/equatable.dart';

class AjouterTransaction implements CasUtilisation<void, ParametresTransaction> {
  final DepotTransaction depot;

  AjouterTransaction(this.depot);

  @override
  Future<Either<Echec, void>> call(ParametresTransaction params) async {
    return await depot.ajouterTransaction(params.transaction);
  }
}

class ParametresTransaction extends Equatable {
  final TransactionEntity transaction;

  const ParametresTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}
