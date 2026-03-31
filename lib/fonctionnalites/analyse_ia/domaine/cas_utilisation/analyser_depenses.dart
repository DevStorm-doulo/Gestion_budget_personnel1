import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../depots/depot_analyse_ia.dart';
import '../entites/conseil_ia.dart';

// ─────────────────────────────────────────────
// Cas d'utilisation : Analyser les dépenses
// ─────────────────────────────────────────────
class AnalyserDepenses implements CasUtilisation<List<ConseilIA>, ParametresAnalyse> {
  final DepotAnalyseIA depot;

  AnalyserDepenses(this.depot);

  @override
  Future<Either<Echec, List<ConseilIA>>> call(ParametresAnalyse params) async {
    return await depot.analyserDepenses(params.utilisateurId);
  }
}

class ParametresAnalyse {
  final String utilisateurId;

  const ParametresAnalyse(this.utilisateurId);
}
