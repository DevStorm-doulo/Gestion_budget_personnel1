import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// Entité Budget - Domaine
// ─────────────────────────────────────────────
class Budget extends Equatable {
  final String id;
  final String categorieId;
  final String nomCategorie;
  final double montantLimite;
  final double montantDepense;
  final int mois;
  final int annee;
  final DateTime dateCreation;
  final DateTime? dateModification;
  
  const Budget({
    required this.id,
    required this.categorieId,
    required this.nomCategorie,
    required this.montantLimite,
    this.montantDepense = 0.0,
    required this.mois,
    required this.annee,
    required this.dateCreation,
    this.dateModification,
  });
  
  /// Retourne le pourcentage de consommation (0.0 à 1.0+)
  double get pourcentage {
    if (montantLimite <= 0) return 0;
    return (montantDepense / montantLimite).clamp(0.0, 1.0);
  }
  
  /// Vérifie si le budget est dépassé
  bool get estDepasse => montantDepense > montantLimite;
  
  /// Vérifie si le budget est en alerte (> 80%)
  bool get estEnAlerte => pourcentage >= 0.8 && !estDepasse;
  
  /// Retourne le montant restant
  double get montantRestant => (montantLimite - montantDepense).clamp(0, double.infinity);
  
  /// Crée une copie avec les champs modifiés
  Budget copyWith({
    String? id,
    String? categorieId,
    String? nomCategorie,
    double? montantLimite,
    double? montantDepense,
    int? mois,
    int? annee,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Budget(
      id: id ?? this.id,
      categorieId: categorieId ?? this.categorieId,
      nomCategorie: nomCategorie ?? this.nomCategorie,
      montantLimite: montantLimite ?? this.montantLimite,
      montantDepense: montantDepense ?? this.montantDepense,
      mois: mois ?? this.mois,
      annee: annee ?? this.annee,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        categorieId,
        nomCategorie,
        montantLimite,
        montantDepense,
        mois,
        annee,
        dateCreation,
        dateModification,
      ];
}
