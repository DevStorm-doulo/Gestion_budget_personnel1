import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_transaction.dart';
import 'ajouter_transaction.dart';

class ModifierTransaction implements CasUtilisation<void, ParametresTransaction> {
  final DepotTransaction depot;

  ModifierTransaction(this.depot);

  @override
  Future<Either<Echec, void>> call(ParametresTransaction params) async {
    return await depot.modifierTransaction(params.transaction);
  }
}
