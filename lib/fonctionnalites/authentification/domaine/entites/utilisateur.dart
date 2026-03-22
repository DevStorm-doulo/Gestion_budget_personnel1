import 'package:equatable/equatable.dart';

class Utilisateur extends Equatable {
  final String id;
  final String email;
  final String nomAffichage;

  const Utilisateur({
    required this.id,
    required this.email,
    required this.nomAffichage,
  });

  @override
  List<Object> get props => [id, email, nomAffichage];
}
