import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domaine/entites/budget.dart';

// ─────────────────────────────────────────────
// Modèle Budget - Données
// ─────────────────────────────────────────────
class BudgetModele extends Budget {
  const BudgetModele({
    required super.id,
    required super.categorieId,
    required super.nomCategorie,
    required super.montantLimite,
    super.montantDepense = 0.0,
    required super.mois,
    required super.annee,
    required super.dateCreation,
    super.dateModification,
  });
  
  /// Crée un BudgetModele à partir d'un document Firestore
  factory BudgetModele.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModele(
      id: doc.id,
      categorieId: data['categorieId'] as String,
      nomCategorie: data['nomCategorie'] as String,
      montantLimite: (data['montantLimite'] as num).toDouble(),
      montantDepense: (data['montantDepense'] as num?)?.toDouble() ?? 0.0,
      mois: data['mois'] as int,
      annee: data['annee'] as int,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: data['dateModification'] != null
          ? (data['dateModification'] as Timestamp).toDate()
          : null,
    );
  }
  
  /// Crée un BudgetModele à partir d'une Map
  factory BudgetModele.fromMap(Map<String, dynamic> map) {
    return BudgetModele(
      id: map['id'] as String,
      categorieId: map['categorieId'] as String,
      nomCategorie: map['nomCategorie'] as String,
      montantLimite: (map['montantLimite'] as num).toDouble(),
      montantDepense: (map['montantDepense'] as num?)?.toDouble() ?? 0.0,
      mois: map['mois'] as int,
      annee: map['annee'] as int,
      dateCreation: DateTime.parse(map['dateCreation'] as String),
      dateModification: map['dateModification'] != null
          ? DateTime.parse(map['dateModification'] as String)
          : null,
    );
  }
  
  /// Convertit le modèle en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'categorieId': categorieId,
      'nomCategorie': nomCategorie,
      'montantLimite': montantLimite,
      'montantDepense': montantDepense,
      'mois': mois,
      'annee': annee,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': dateModification != null
          ? Timestamp.fromDate(dateModification!)
          : null,
    };
  }
  
  /// Convertit le modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categorieId': categorieId,
      'nomCategorie': nomCategorie,
      'montantLimite': montantLimite,
      'montantDepense': montantDepense,
      'mois': mois,
      'annee': annee,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }
  
  /// Crée une copie avec les champs modifiés
  @override
  BudgetModele copyWith({
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
    return BudgetModele(
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
}
