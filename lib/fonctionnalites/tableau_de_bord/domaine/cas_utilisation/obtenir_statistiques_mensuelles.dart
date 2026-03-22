import 'package:dartz/dartz.dart';
import '../../../../core/cas_utilisation/cas_utilisation.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../transactions/domaine/depots/depot_transaction.dart';

class StatistiquesMensuelles {
  final double totalRevenus;
  final double totalDepenses;
  final Map<String, double> depensesParCategorie;

  StatistiquesMensuelles({
    required this.totalRevenus,
    required this.totalDepenses,
    required this.depensesParCategorie,
  });
}

class ObtenirStatistiquesMensuelles implements CasUtilisation<StatistiquesMensuelles, SansParametres> {
  final DepotTransaction depot;

  ObtenirStatistiquesMensuelles(this.depot);

  @override
  Future<Either<Echec, StatistiquesMensuelles>> call(SansParametres params) async {
    final result = await depot.obtenirTransactions();
    
    return result.map((transactions) {
      final maintenant = DateTime.now();
      double totalRevenus = 0.0;
      double totalDepenses = 0.0;
      Map<String, double> depensesParCategorie = {};

      for (var t in transactions) {
        // Filtrer par mois courant
        if (t.date.month == maintenant.month && t.date.year == maintenant.year) {
          if (t.type == 'income') {
            totalRevenus += t.amount;
          } else {
            totalDepenses += t.amount;
            depensesParCategorie[t.category] = (depensesParCategorie[t.category] ?? 0) + t.amount;
          }
        }
      }

      return StatistiquesMensuelles(
        totalRevenus: totalRevenus,
        totalDepenses: totalDepenses,
        depensesParCategorie: depensesParCategorie,
      );
    });
  }
}
