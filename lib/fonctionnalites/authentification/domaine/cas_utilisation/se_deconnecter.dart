import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_authentification.dart';

class SeDeconnecter implements CasUtilisation<void, SansParametres> {
  final DepotAuthentification depot;

  SeDeconnecter(this.depot);

  @override
  Future<Either<Echec, void>> call(SansParametres params) async {
    return await depot.seDeconnecter();
  }
}
