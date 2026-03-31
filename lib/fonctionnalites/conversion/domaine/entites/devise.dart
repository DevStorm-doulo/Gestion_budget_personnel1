import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// Entité Devise - Domaine
// ─────────────────────────────────────────────
class Devise extends Equatable {
  final String code;
  final String nom;
  final String symbole;
  final String drapeau;

  const Devise({
    required this.code,
    required this.nom,
    required this.symbole,
    required this.drapeau,
  });

  @override
  List<Object?> get props => [code, nom, symbole, drapeau];

  // Liste des devises supportées
  static const List<Devise> devises = [
    Devise(
      code: 'XOF',
      nom: 'Franc CFA',
      symbole: 'FCFA',
      drapeau: '🌍',
    ),
    Devise(
      code: 'XAF',
      nom: 'Franc CFA BEAC',
      symbole: 'FCFA',
      drapeau: '🌍',
    ),
    Devise(
      code: 'USD',
      nom: 'Dollar américain',
      symbole: '\$',
      drapeau: '🇺🇸',
    ),
    Devise(
      code: 'EUR',
      nom: 'Euro',
      symbole: '€',
      drapeau: '🇪🇺',
    ),
    Devise(
      code: 'GBP',
      nom: 'Livre sterling',
      symbole: '£',
      drapeau: '🇬🇧',
    ),
    Devise(
      code: 'CNY',
      nom: 'Yuan chinois',
      symbole: '¥',
      drapeau: '🇨🇳',
    ),
  ];

  // Trouver une devise par son code
  static Devise? trouverParCode(String code) {
    try {
      return devises.firstWhere((d) => d.code == code);
    } catch (e) {
      return null;
    }
  }
}
