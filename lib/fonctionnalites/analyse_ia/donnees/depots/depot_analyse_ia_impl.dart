import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/depots/depot_analyse_ia.dart';
import '../../domaine/entites/conseil_ia.dart';
import '../sources_donnees/source_analyse_gemini.dart';

// ─────────────────────────────────────────────
// Implémentation du dépôt Analyse IA - Données
// ─────────────────────────────────────────────
class DepotAnalyseIAImpl implements DepotAnalyseIA {
  final SourceAnalyseGeminiImpl sourceGemini;
  final FirebaseFirestore firestore;

  DepotAnalyseIAImpl({
    required this.sourceGemini,
    required this.firestore,
  });

  @override
  Future<Either<Echec, List<ConseilIA>>> analyserDepenses(
      String utilisateurId) async {
    try {
      final maintenant = DateTime.now();
      final cleMois = '${maintenant.year}_${maintenant.month.toString().padLeft(2, '0')}';

      final conseilsCaches = await _obtenirConseilsCaches(utilisateurId, cleMois);
      if (conseilsCaches != null) {
        return Right(conseilsCaches);
      }

      final transactionsMois =
          await _obtenirTransactionsMois(utilisateurId, maintenant);

      double totalRevenus = 0;
      double totalDepenses = 0;
      final Map<String, double> depensesParCategorie = {};

      for (final transaction in transactionsMois) {
        final type = transaction['type'] as String? ?? '';
        final montant = (transaction['amount'] as num?)?.toDouble() ?? 0;
        final categorie = transaction['category'] as String? ?? '';

        if (type == 'income') {
          totalRevenus += montant;
        } else {
          totalDepenses += montant;
          depensesParCategorie[categorie] =
              (depensesParCategorie[categorie] ?? 0) + montant;
        }
      }

      final solde = totalRevenus - totalDepenses;

      final moisPrecedent =
          DateTime(maintenant.year, maintenant.month - 1, 1);
      final transactionsMoisPrecedent =
          await _obtenirTransactionsMois(utilisateurId, moisPrecedent);

      double totalDepensesPrecedent = 0;
      for (final transaction in transactionsMoisPrecedent) {
        if (transaction['type'] == 'expense') {
          totalDepensesPrecedent +=
              (transaction['amount'] as num?)?.toDouble() ?? 0;
        }
      }

      String comparaison;
      if (totalDepensesPrecedent > 0) {
        final variation =
            ((totalDepenses - totalDepensesPrecedent) / totalDepensesPrecedent * 100)
                .toStringAsFixed(1);
        comparaison = totalDepenses > totalDepensesPrecedent
            ? 'Dépenses en hausse de $variation% par rapport au mois précédent'
            : 'Dépenses en baisse de ${variation.replaceAll('-', '')}% par rapport au mois précédent';
      } else {
        comparaison = 'Aucune donnée du mois précédent pour comparaison';
      }

      final budgetsDepasses = await _obtenirBudgetsDepasses(utilisateurId);

      final donnees = {
        'solde': solde,
        'totalRevenus': totalRevenus,
        'totalDepenses': totalDepenses,
        'depensesParCategorie': depensesParCategorie,
        'budgetDepasses': budgetsDepasses,
        'comparaison': comparaison,
      };

      final conseils = await sourceGemini.analyserDepenses(donnees);

      await _sauvegarderConseils(utilisateurId, cleMois, conseils);

      return Right(conseils);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } catch (e) {
      return Left(EchecServeur('Erreur lors de l\'analyse des dépenses: $e'));
    }
  }

  Future<List<Map<String, dynamic>>> _obtenirTransactionsMois(
      String utilisateurId, DateTime mois) async {
    final debutMois = DateTime(mois.year, mois.month, 1);
    final finMois = DateTime(mois.year, mois.month + 1, 0, 23, 59, 59);

    final snapshot = await firestore
        .collection('transactions')
        .where('userId', isEqualTo: utilisateurId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(debutMois))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(finMois))
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw ExceptionServeur('Délai d\'attente dépassé'),
        );

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> _obtenirBudgetsDepasses(String utilisateurId) async {
    final maintenant = DateTime.now();

    try {
      final snapshot = await firestore
          .collection('budgets')
          .where('utilisateurId', isEqualTo: utilisateurId)
          .where('mois', isEqualTo: maintenant.month)
          .where('annee', isEqualTo: maintenant.year)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ExceptionServeur('Délai d\'attente dépassé'),
          );

      final budgetsDepasses = <String>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final montantLimite = (data['montantLimite'] as num?)?.toDouble() ?? 0;
        final montantDepense = (data['montantDepense'] as num?)?.toDouble() ?? 0;
        final nomCategorie = data['nomCategorie'] as String? ?? '';

        if (montantDepense > montantLimite && nomCategorie.isNotEmpty) {
          budgetsDepasses.add(nomCategorie);
        }
      }
      return budgetsDepasses;
    } catch (e) {
      return [];
    }
  }

  Future<List<ConseilIA>?> _obtenirConseilsCaches(
      String utilisateurId, String cleMois) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(utilisateurId)
          .collection('conseils_ia')
          .doc(cleMois)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ExceptionServeur('Délai d\'attente dépassé'),
          );

      if (!doc.exists) return null;

      final data = doc.data()!;
      final dateGenerationStr = data['dateGeneration'] as String?;
      if (dateGenerationStr == null) return null;

      final dateGeneration = DateTime.parse(dateGenerationStr);
      final maintenant = DateTime.now();

      if (maintenant.difference(dateGeneration).inHours < 24) {
        final conseilsData = data['conseils'] as List<dynamic>?;
        if (conseilsData == null) return null;

        return conseilsData
            .map((item) =>
                ConseilIA.depuisFirestore(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _sauvegarderConseils(
      String utilisateurId, String cleMois, List<ConseilIA> conseils) async {
    try {
      await firestore
          .collection('users')
          .doc(utilisateurId)
          .collection('conseils_ia')
          .doc(cleMois)
          .set({
        'dateGeneration': DateTime.now().toIso8601String(),
        'conseils': conseils.map((c) => c.versFirestore()).toList(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw ExceptionServeur('Délai d\'attente dépassé'),
      );
    } catch (e) {
      // Silencieux : la sauvegarde échoue sans bloquer l'affichage
    }
  }
}
