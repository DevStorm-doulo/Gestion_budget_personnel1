import 'package:equatable/equatable.dart';

abstract class Echec extends Equatable {
  final String message;

  const Echec(this.message);

  @override
  List<Object> get props => [message];
}

class EchecServeur extends Echec {
  const EchecServeur(super.message);
}

class EchecAuthentification extends Echec {
  const EchecAuthentification(super.message);
}

class EchecValidation extends Echec {
  const EchecValidation(super.message);
}
