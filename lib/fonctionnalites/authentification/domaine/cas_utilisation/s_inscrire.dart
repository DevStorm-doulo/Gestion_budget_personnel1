import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_authentification.dart';
import '../entites/utilisateur.dart';
import 'package:equatable/equatable.dart';

class SInscrire implements CasUtilisation<Utilisateur, ParametresInscription> {
  final DepotAuthentification depot;

  SInscrire(this.depot);

  @override
  Future<Either<Echec, Utilisateur>> call(ParametresInscription params) async {
    return await depot.sInscrire(params.email, params.motDePasse, params.nomAffichage);
  }
}

class ParametresInscription extends Equatable {
  final String email;
  final String motDePasse;
  final String nomAffichage;

  const ParametresInscription({
    required this.email,
    required this.motDePasse,
    required this.nomAffichage,
  });

  @override
  List<Object> get props => [email, motDePasse, nomAffichage];
}
