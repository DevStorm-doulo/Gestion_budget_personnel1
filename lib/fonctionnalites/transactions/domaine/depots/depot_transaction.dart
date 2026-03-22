import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/transaction.dart';

abstract class DepotTransaction {
  Future<Either<Echec, List<TransactionEntity>>> obtenirTransactions();
  Future<Either<Echec, void>> ajouterTransaction(TransactionEntity transaction);
  Future<Either<Echec, void>> modifierTransaction(TransactionEntity transaction);
  Future<Either<Echec, void>> supprimerTransaction(String id);
}
