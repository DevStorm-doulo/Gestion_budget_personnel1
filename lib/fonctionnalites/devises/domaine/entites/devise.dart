import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// Entité Devise - Domaine
// ─────────────────────────────────────────────
class Devise extends Equatable {
  final String code;
  final String nom;
  final String symbole;
  final double tauxVersXof;

  const Devise({
    required this.code,
    required this.nom,
    required this.symbole,
    required this.tauxVersXof,
  });

  /// Liste des devises supportées
  static const List<Devise> devisesSupportees = [
    Devise(
      code: 'XOF',
      nom: 'Franc CFA',
      symbole: 'FCFA',
      tauxVersXof: 1.0,
    ),
    Devise(
      code: 'EUR',
      nom: 'Euro',
      symbole: '\u20AC',
      tauxVersXof: 655.957,
    ),
    Devise(
      code: 'USD',
      nom: 'Dollar am\u00e9ricain',
      symbole: '\u0024',
      tauxVersXof: 600.0,
    ),
    Devise(
      code: 'GBP',
      nom: 'Livre sterling',
      symbole: '\u00A3',
      tauxVersXof: 760.0,
    ),
    Devise(
      code: 'MAD',
      nom: 'Dirham marocain',
      symbole: 'MAD',
      tauxVersXof: 60.0,
    ),
  ];

  /// Trouve une devise par son code
  static Devise trouverParCode(String code) {
    return devisesSupportees.firstWhere(
      (devise) => devise.code == code,
      orElse: () => devisesSupportees.first,
    );
  }

  @override
  List<Object?> get props => [code, nom, symbole, tauxVersXof];
}
