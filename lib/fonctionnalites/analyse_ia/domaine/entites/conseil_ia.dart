import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Entité Conseil IA
// ─────────────────────────────────────────────
class ConseilIA extends Equatable {
  final String id;
  final String titre;
  final String description;
  final String categorie;
  final IconData icone;
  final DateTime dateGeneration;

  const ConseilIA({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.icone,
    required this.dateGeneration,
  });

  static IconData iconeParCategorie(String categorie) {
    switch (categorie) {
      case 'Économies':
        return Icons.savings;
      case 'Dépenses':
        return Icons.trending_down;
      case 'Budget':
        return Icons.account_balance_wallet;
      case 'Revenus':
        return Icons.trending_up;
      default:
        return Icons.lightbulb;
    }
  }

  static Color couleurParCategorie(String categorie) {
    switch (categorie) {
      case 'Économies':
        return const Color(0xFF4CAF50);
      case 'Dépenses':
        return const Color(0xFFE53935);
      case 'Budget':
        return const Color(0xFF1E88E5);
      case 'Revenus':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  factory ConseilIA.depuisJson(Map<String, dynamic> json, int index) {
    final categorie = json['categorie'] as String? ?? 'Budget';
    return ConseilIA(
      id: 'conseil_${DateTime.now().millisecondsSinceEpoch}_$index',
      titre: json['titre'] as String? ?? 'Conseil financier',
      description:
          json['description'] as String? ?? 'Analysez vos dépenses régulièrement.',
      categorie: categorie,
      icone: iconeParCategorie(categorie),
      dateGeneration: DateTime.now(),
    );
  }

  Map<String, dynamic> versFirestore() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'dateGeneration': dateGeneration.toIso8601String(),
    };
  }

  factory ConseilIA.depuisFirestore(Map<String, dynamic> data) {
    final categorie = data['categorie'] as String? ?? 'Budget';
    return ConseilIA(
      id: data['id'] as String? ?? '',
      titre: data['titre'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categorie: categorie,
      icone: iconeParCategorie(categorie),
      dateGeneration: data['dateGeneration'] != null
          ? DateTime.parse(data['dateGeneration'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, titre, description, categorie, icone, dateGeneration];
}
