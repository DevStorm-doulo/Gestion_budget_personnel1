import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_authentification.dart';
import '../entites/utilisateur.dart';

class ObtenirUtilisateurActuel implements CasUtilisation<Utilisateur?, SansParametres> {
  final DepotAuthentification depot;

  ObtenirUtilisateurActuel(this.depot);

  @override
  Future<Either<Echec, Utilisateur?>> call(SansParametres params) async {
    return await depot.obtenirUtilisateurActuel();
  }
}
