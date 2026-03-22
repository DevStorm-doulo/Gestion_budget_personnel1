import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_authentification.dart';
import '../entites/utilisateur.dart';
import 'package:equatable/equatable.dart';

class SeConnecter implements CasUtilisation<Utilisateur, ParametresConnexion> {
  final DepotAuthentification depot;

  SeConnecter(this.depot);

  @override
  Future<Either<Echec, Utilisateur>> call(ParametresConnexion params) async {
    return await depot.seConnecter(params.email, params.motDePasse);
  }
}

class ParametresConnexion extends Equatable {
  final String email;
  final String motDePasse;

  const ParametresConnexion({required this.email, required this.motDePasse});

  @override
  List<Object> get props => [email, motDePasse];
}
