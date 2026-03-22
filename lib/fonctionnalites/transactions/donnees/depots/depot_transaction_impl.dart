import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/depots/depot_transaction.dart';
import '../../domaine/entites/transaction.dart';
import '../modeles/transaction_modele.dart';
import '../sources_donnees/source_transaction_firebase.dart';

class DepotTransactionImpl implements DepotTransaction {
  final SourceTransactionFirebase sourceBdd;

  DepotTransactionImpl({required this.sourceBdd});

  @override
  Future<Either<Echec, List<TransactionEntity>>> obtenirTransactions() async {
    try {
      final transactions = await sourceBdd.obtenirTransactions();
      return Right(transactions);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, void>> ajouterTransaction(TransactionEntity transaction) async {
    try {
      final modele = TransactionModele.depuisEntite(transaction);
      await sourceBdd.ajouterTransaction(modele);
      return const Right(null);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, void>> modifierTransaction(TransactionEntity transaction) async {
    try {
      final modele = TransactionModele.depuisEntite(transaction);
      await sourceBdd.modifierTransaction(modele);
      return const Right(null);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }

  @override
  Future<Either<Echec, void>> supprimerTransaction(String id) async {
    try {
      await sourceBdd.supprimerTransaction(id);
      return const Right(null);
    } on ExceptionAuthentification catch (e) {
      return Left(EchecAuthentification(e.message));
    } on ExceptionServeur catch (e) {
      return Left(EchecServeur(e.message));
    }
  }
}
