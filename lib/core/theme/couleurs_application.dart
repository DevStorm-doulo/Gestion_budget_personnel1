import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Palette de couleurs premium - Style Banking App
// ─────────────────────────────────────────────
class CouleursApplication {
  // Couleurs principales (violet profond)
  static const Color primaire = Color(0xFF6C63FF);
  static const Color primaireFonce = Color(0xFF5A52E0);
  static const Color primaireClair = Color(0xFF8B85FF);
  
  // Couleurs secondaires
  static const Color secondaire = Color(0xFFEC4899);
  static const Color secondaireFonce = Color(0xFFDB2777);
  static const Color secondaireClair = Color(0xFFF472B6);
  
  // Couleurs de fond (blanc cassé)
  static const Color fond = Color(0xFFF8F9FA);
  static const Color fondCarte = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F5);
  
  // Couleurs de texte
  static const Color textePrincipal = Color(0xFF1A1A2E);
  static const Color texteSecondaire = Color(0xFF6B7280);
  static const Color texteClair = Color(0xFF9CA3AF);
  static const Color texteSurPrimaire = Color(0xFFFFFFFF);
  
  // Couleurs d'état
  static const Color succes = Color(0xFF10B981);
  static const Color succesClair = Color(0xFFD1FAE5);
  static const Color erreur = Color(0xFFEF4444);
  static const Color erreurClair = Color(0xFFFEE2E2);
  static const Color avertissement = Color(0xFFF59E0B);
  static const Color avertissementClair = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoClair = Color(0xFFDBEAFE);
  
  // Couleurs de catégories
  static const Color categorieSalaire = Color(0xFF10B981);
  static const Color categorieBourse = Color(0xFF6C63FF);
  static const Color categorieAide = Color(0xFF8B5CF6);
  static const Color categorieTransport = Color(0xFF3B82F6);
  static const Color categorieAlimentation = Color(0xFFF59E0B);
  static const Color categorieLoyer = Color(0xFFEC4899);
  static const Color categorieLoisirs = Color(0xFF14B8A6);
  static const Color categorieSante = Color(0xFFEF4444);
  static const Color categorieAutre = Color(0xFF6B7280);
  
  // ── Dégradés élégants ──
  static const LinearGradient degradePrimaire = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeSecondaire = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeSucces = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeErreur = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeAvertissement = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dégradé premium pour la carte principale
  static const LinearGradient degradePremium = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
  
  // Dégradé subtil pour les arrière-plans
  static const LinearGradient degradeFondSubtil = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ── Méthodes utilitaires ──
  
  /// Retourne la couleur correspondant à une catégorie
  static Color couleurParCategorie(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'salaire':
        return categorieSalaire;
      case 'bourse':
        return categorieBourse;
      case 'aide':
        return categorieAide;
      case 'transport':
        return categorieTransport;
      case 'alimentation':
        return categorieAlimentation;
      case 'loyer':
        return categorieLoyer;
      case 'loisirs':
        return categorieLoisirs;
      case 'sante':
        return categorieSante;
      default:
        return categorieAutre;
    }
  }
  
  /// Retourne une couleur avec opacité
  static Color avecOpacite(Color couleur, double opacite) {
    return couleur.withValues(alpha: opacite);
  }
  
  /// Retourne la couleur de progression selon le pourcentage
  /// Vert < 50%, Orange 50-80%, Rouge > 80%
  static Color couleurProgression(double pourcentage) {
    if (pourcentage < 0.5) {
      return succes;
    } else if (pourcentage < 0.8) {
      return avertissement;
    } else {
      return erreur;
    }
  }
  
  /// Retourne le dégradé de progression selon le pourcentage
  static LinearGradient degradeProgression(double pourcentage) {
    if (pourcentage < 0.5) {
      return degradeSucces;
    } else if (pourcentage < 0.8) {
      return degradeAvertissement;
    } else {
      return degradeErreur;
    }
  }
}
