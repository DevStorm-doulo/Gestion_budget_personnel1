import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/conseil_ia.dart';

// ─────────────────────────────────────────────
// Interface dépôt Analyse IA - Domaine
// ─────────────────────────────────────────────
abstract class DepotAnalyseIA {
  Future<Either<Echec, List<ConseilIA>>> analyserDepenses(String utilisateurId);
}
