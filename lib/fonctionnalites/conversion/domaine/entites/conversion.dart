import 'package:equatable/equatable.dart';
import 'devise.dart';

// ─────────────────────────────────────────────
// Entité Conversion - Domaine
// ─────────────────────────────────────────────
class Conversion extends Equatable {
  final String id;
  final double montantSource;
  final double montantCible;
  final Devise deviseSource;
  final Devise deviseCible;
  final double tauxChange;
  final DateTime dateConversion;

  const Conversion({
    required this.id,
    required this.montantSource,
    required this.montantCible,
    required this.deviseSource,
    required this.deviseCible,
    required this.tauxChange,
    required this.dateConversion,
  });

  @override
  List<Object?> get props => [
        id,
        montantSource,
        montantCible,
        deviseSource,
        deviseCible,
        tauxChange,
        dateConversion,
      ];

  // Créer une copie avec des modifications
  Conversion copyWith({
    String? id,
    double? montantSource,
    double? montantCible,
    Devise? deviseSource,
    Devise? deviseCible,
    double? tauxChange,
    DateTime? dateConversion,
  }) {
    return Conversion(
      id: id ?? this.id,
      montantSource: montantSource ?? this.montantSource,
      montantCible: montantCible ?? this.montantCible,
      deviseSource: deviseSource ?? this.deviseSource,
      deviseCible: deviseCible ?? this.deviseCible,
      tauxChange: tauxChange ?? this.tauxChange,
      dateConversion: dateConversion ?? this.dateConversion,
    );
  }

  // Convertir en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montantSource': montantSource,
      'montantCible': montantCible,
      'deviseSource': deviseSource.code,
      'deviseCible': deviseCible.code,
      'tauxChange': tauxChange,
      'dateConversion': dateConversion.toIso8601String(),
    };
  }

  // Créer depuis une Map
  factory Conversion.fromMap(Map<String, dynamic> map) {
    return Conversion(
      id: map['id'] as String,
      montantSource: (map['montantSource'] as num).toDouble(),
      montantCible: (map['montantCible'] as num).toDouble(),
      deviseSource: Devise.trouverParCode(map['deviseSource'] as String) ?? Devise.devises[0],
      deviseCible: Devise.trouverParCode(map['deviseCible'] as String) ?? Devise.devises[0],
      tauxChange: (map['tauxChange'] as num).toDouble(),
      dateConversion: DateTime.parse(map['dateConversion'] as String),
    );
  }
}
