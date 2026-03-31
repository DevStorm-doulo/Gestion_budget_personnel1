import 'package:intl/intl.dart';
import '../../fonctionnalites/devises/domaine/entites/devise.dart';

// ─────────────────────────────────────────────
// Formateur de montant
// ─────────────────────────────────────────────
class FormateurMontant {
  /// Formate un montant selon la devise
  static String formater(double montant, Devise devise) {
    switch (devise.code) {
      case 'XOF':
        return _formaterXof(montant);
      case 'EUR':
        return _formaterEur(montant);
      case 'USD':
        return _formaterUsd(montant);
      case 'GBP':
        return _formaterGbp(montant);
      case 'MAD':
        return _formaterMad(montant);
      default:
        return _formaterXof(montant);
    }
  }

  /// Formate un montant en XOF (Franc CFA)
  static String _formaterXof(double montant) {
    final formateur = NumberFormat('#,##0', 'fr_FR');
    final montantFormate = formateur.format(montant.abs());
    final signe = montant < 0 ? '-' : '';
    return '$signe$montantFormate FCFA';
  }

  /// Formate un montant en EUR (Euro)
  static String _formaterEur(double montant) {
    final formateur = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '\u20AC',
      decimalDigits: 2,
    );
    return formateur.format(montant);
  }

  /// Formate un montant en USD (Dollar américain)
  static String _formaterUsd(double montant) {
    final formateur = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\u0024',
      decimalDigits: 2,
    );
    return formateur.format(montant);
  }

  /// Formate un montant en GBP (Livre sterling)
  static String _formaterGbp(double montant) {
    final formateur = NumberFormat.currency(
      locale: 'en_GB',
      symbol: '\u00A3',
      decimalDigits: 2,
    );
    return formateur.format(montant);
  }

  /// Formate un montant en MAD (Dirham marocain)
  static String _formaterMad(double montant) {
    final formateur = NumberFormat('#,##0.00', 'fr_FR');
    final montantFormate = formateur.format(montant.abs());
    final signe = montant < 0 ? '-' : '';
    return '$signe$montantFormate MAD';
  }
}
