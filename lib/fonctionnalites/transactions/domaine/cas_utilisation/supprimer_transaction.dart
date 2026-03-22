import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_transaction.dart';
import 'package:equatable/equatable.dart';

class SupprimerTransaction implements CasUtilisation<void, ParametresSuppression> {
  final DepotTransaction depot;

  SupprimerTransaction(this.depot);

  @override
  Future<Either<Echec, void>> call(ParametresSuppression params) async {
    return await depot.supprimerTransaction(params.id);
  }
}

class ParametresSuppression extends Equatable {
  final String id;

  const ParametresSuppression(this.id);

  @override
  List<Object> get props => [id];
}
