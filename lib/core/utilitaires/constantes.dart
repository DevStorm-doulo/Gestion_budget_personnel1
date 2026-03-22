import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Palette de couleurs centralisée
// ─────────────────────────────────────────────
class CodeCouleurs {
  // Couleurs principales
  static const Color primaire = Color(0xFF6366F1);
  static const Color primaireFonce = Color(0xFF4F46E5);
  static const Color secondaire = Color(0xFFEC4899);
  static const Color secondaireFonce = Color(0xFFDB2777);
  
  // Couleurs de fond
  static const Color fond = Color(0xFFF8FAFC);
  static const Color fondCarte = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Couleurs de texte
  static const Color textePrincipal = Color(0xFF1E293B);
  static const Color texteSecondaire = Color(0xFF64748B);
  static const Color texteClair = Color(0xFF94A3B8);
  
  // Couleurs d'état
  static const Color rouge = Color(0xFFEF4444);
  static const Color rougeClair = Color(0xFFFEE2E2);
  static const Color vert = Color(0xFF10B981);
  static const Color vertClair = Color(0xFFD1FAE5);
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeClair = Color(0xFFFEF3C7);
  static const Color bleu = Color(0xFF3B82F6);
  static const Color bleuClair = Color(0xFFDBEAFE);
  
  // Dégradés
  static const LinearGradient degradePrimaire = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeSecondaire = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeVert = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient degradeRouge = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
// Espacement
// ─────────────────────────────────────────────
class Marges {
  static const double petite = 8.0;
  static const double moyenne = 16.0;
  static const double grande = 24.0;
  static const double enorme = 32.0;
}

// ─────────────────────────────────────────────
// Système de design
// ─────────────────────────────────────────────
class DesignSystem {
  static const double rayonBordureDefaut = 20.0;
  static const double rayonBordurePetit = 12.0;
  static const double rayonBordureGrand = 28.0;

  // Ombres
  static List<BoxShadow> ombreDouce = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> ombreMoyenne = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> ombreColoree = [
    BoxShadow(
      color: CodeCouleurs.primaire.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> ombreSecondaire = [
    BoxShadow(
      color: CodeCouleurs.secondaire.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Dégradés (raccourcis vers CodeCouleurs)
  static const LinearGradient degradePrimaire = CodeCouleurs.degradePrimaire;
  static const LinearGradient degradeSecondaire = CodeCouleurs.degradeSecondaire;
  static const LinearGradient degradeVert = CodeCouleurs.degradeVert;
  static const LinearGradient degradeRouge = CodeCouleurs.degradeRouge;
  
  // Animations
  static const Duration animationRapide = Duration(milliseconds: 200);
  static const Duration animationMoyenne = Duration(milliseconds: 300);
  static const Duration animationLente = Duration(milliseconds: 500);
  
  // Courbes
  static const Curve courbeAnimation = Curves.easeInOutCubic;
}

// ─────────────────────────────────────────────
// Helpers globaux
// ─────────────────────────────────────────────

/// Formate un montant en FCFA avec séparateur d'espaces (ex: 1 500 000)
String formatFCFA(double montant) {
  final n = montant.abs().toInt();
  final str = n.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

// ─────────────────────────────────────────────
// Catégories — icônes et couleurs
// ─────────────────────────────────────────────
const Map<String, IconData> iconeParCategorie = {
  'salaire': Icons.work_rounded,
  'bourse': Icons.school_rounded,
  'aide': Icons.volunteer_activism_rounded,
  'transport': Icons.directions_bus_rounded,
  'alimentation': Icons.restaurant_rounded,
  'loyer': Icons.home_rounded,
  'loisirs': Icons.sports_esports_rounded,
  'sante': Icons.local_hospital_rounded,
  'autre': Icons.category_rounded,
};

const Map<String, Color> couleurParCategorie = {
  'salaire': Color(0xFF10B981),
  'bourse': Color(0xFF6366F1),
  'aide': Color(0xFF8B5CF6),
  'transport': Color(0xFF3B82F6),
  'alimentation': Color(0xFFF59E0B),
  'loyer': Color(0xFFEC4899),
  'loisirs': Color(0xFF14B8A6),
  'sante': Color(0xFFEF4444),
  'autre': Color(0xFF64748B),
};

IconData iconeCategorie(String categorie) =>
    iconeParCategorie[categorie] ?? Icons.category_rounded;

Color couleurCategorie(String categorie) =>
    couleurParCategorie[categorie] ?? CodeCouleurs.primaire;
