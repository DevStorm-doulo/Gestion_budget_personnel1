import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// Modèle de résultat OCR pour les reçus
// ─────────────────────────────────────────────
class ResultatScan extends Equatable {
  final double? montant;
  final DateTime? date;
  final String? nomCommerce;
  final String? description;
  final String texteComplet;
  final double confiance;

  const ResultatScan({
    this.montant,
    this.date,
    this.nomCommerce,
    this.description,
    required this.texteComplet,
    required this.confiance,
  });

  /// Vérifie si le scan a détecté un montant valide
  bool get estValide => montant != null && montant! > 0;

  /// Vérifie si le scan a détecté toutes les informations
  bool get estComplet => montant != null && date != null && nomCommerce != null;

  /// Crée une copie avec les champs modifiés
  ResultatScan copyWith({
    double? montant,
    DateTime? date,
    String? nomCommerce,
    String? description,
    String? texteComplet,
    double? confiance,
  }) {
    return ResultatScan(
      montant: montant ?? this.montant,
      date: date ?? this.date,
      nomCommerce: nomCommerce ?? this.nomCommerce,
      description: description ?? this.description,
      texteComplet: texteComplet ?? this.texteComplet,
      confiance: confiance ?? this.confiance,
    );
  }

  /// Convertit en Map pour le debug/logging
  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'date': date?.toIso8601String(),
      'nomCommerce': nomCommerce,
      'description': description,
      'texteComplet': texteComplet,
      'confiance': confiance,
    };
  }

  @override
  List<Object?> get props => [
        montant,
        date,
        nomCommerce,
        description,
        texteComplet,
        confiance,
      ];
}
