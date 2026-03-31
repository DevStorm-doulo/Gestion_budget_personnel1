import 'package:dartz/dartz.dart';
import '../../../../core/erreurs/echecs.dart';
import '../entites/devise.dart';

// ─────────────────────────────────────────────
// Interface du dépôt Devise - Domaine
// ─────────────────────────────────────────────
abstract class DepotDevise {
  /// Obtient toutes les devises supportées
  Future<Either<Echec, List<Devise>>> obtenirDevises();
  
  /// Obtient la devise active de l'utilisateur
  Future<Either<Echec, Devise>> obtenirDeviseActive();
  
  /// Change la devise active de l'utilisateur
  Future<Either<Echec, void>> changerDevise(String code);
}
