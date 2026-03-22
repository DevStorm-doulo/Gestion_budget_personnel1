import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../erreurs/echecs.dart';

abstract class CasUtilisation<Type, Params> {
  Future<Either<Echec, Type>> call(Params params);
}

class SansParametres extends Equatable {
  @override
  List<Object> get props => [];
}
