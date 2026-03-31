import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'couleurs_application.dart';

// ─────────────────────────────────────────────
// Thème premium de l'application
// ─────────────────────────────────────────────
class ThemeApplication {
  // ── Rayons de bordure ──
  static const double rayonPetit = 12.0;
  static const double rayonMoyen = 16.0;
  static const double rayonGrand = 20.0;
  static const double rayonTresGrand = 24.0;
  static const double rayonCercle = 100.0;
  
  // ── Espacements ──
  static const double espacePetit = 8.0;
  static const double espaceMoyen = 16.0;
  static const double espaceGrand = 24.0;
  static const double espaceTresGrand = 32.0;
  
  // Alias pour compatibilité
  static const double espacePetite = espacePetit;
  static const double espaceMoyenne = espaceMoyen;
  
  // ── Ombres premium ──
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
  
  static List<BoxShadow> ombreForte = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];
  
  static List<BoxShadow> ombreColoree = [
    BoxShadow(
      color: CouleursApplication.primaire.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> ombreSucces = [
    BoxShadow(
      color: CouleursApplication.succes.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> ombreErreur = [
    BoxShadow(
      color: CouleursApplication.erreur.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ── Durées d'animation ──
  static const Duration animationRapide = Duration(milliseconds: 200);
  static const Duration animationMoyenne = Duration(milliseconds: 300);
  static const Duration animationLente = Duration(milliseconds: 500);
  
  // ── Courbes d'animation ──
  static const Curve courbeAnimation = Curves.easeInOutCubic;
  static const Curve courbeRebond = Curves.elasticOut;
  
  // ── ThemeData principal (clair) ──
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs de base
      scaffoldBackgroundColor: CouleursApplication.fond,
      primaryColor: CouleursApplication.primaire,
      
      // ColorScheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: CouleursApplication.primaire,
        primary: CouleursApplication.primaire,
        primaryContainer: CouleursApplication.primaireClair,
        secondary: CouleursApplication.secondaire,
        secondaryContainer: CouleursApplication.secondaireClair,
        surface: CouleursApplication.surface,
        error: CouleursApplication.erreur,
        onPrimary: CouleursApplication.texteSurPrimaire,
        onSecondary: CouleursApplication.texteSurPrimaire,
        onSurface: CouleursApplication.textePrincipal,
        onError: CouleursApplication.texteSurPrimaire,
      ),
      
      // Typographie
      textTheme: _construireTextTheme(),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: CouleursApplication.textePrincipal),
        titleTextStyle: TextStyle(
          color: CouleursApplication.textePrincipal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Cartes
      cardTheme: CardThemeData(
        elevation: 0,
        color: CouleursApplication.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonGrand),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApplication.primaire,
          foregroundColor: CouleursApplication.texteSurPrimaire,
          elevation: 4,
          shadowColor: CouleursApplication.primaire.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rayonMoyen),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CouleursApplication.primaire,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CouleursApplication.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: BorderSide(
            color: CouleursApplication.texteClair.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.primaire,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.erreur,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.erreur,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: espaceMoyen,
          vertical: espaceMoyen,
        ),
        hintStyle: TextStyle(
          color: CouleursApplication.texteClair,
          fontSize: 14,
        ),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CouleursApplication.surface,
        selectedItemColor: CouleursApplication.primaire,
        unselectedItemColor: CouleursApplication.texteSecondaire,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CouleursApplication.primaire,
        foregroundColor: CouleursApplication.texteSurPrimaire,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonMoyen),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: CouleursApplication.texteClair.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CouleursApplication.primaire,
        linearTrackColor: CouleursApplication.surfaceAlt,
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CouleursApplication.textePrincipal,
        contentTextStyle: const TextStyle(
          color: CouleursApplication.texteSurPrimaire,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: CouleursApplication.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonGrand),
        ),
        titleTextStyle: const TextStyle(
          color: CouleursApplication.textePrincipal,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: CouleursApplication.texteSecondaire,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // ── ThemeData sombre ──
  static ThemeData get themeSombre {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Couleurs de base
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: CouleursApplication.primaire,
      
      // ColorScheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: CouleursApplication.primaire,
        brightness: Brightness.dark,
        primary: CouleursApplication.primaire,
        primaryContainer: CouleursApplication.primaireFonce,
        secondary: CouleursApplication.secondaire,
        secondaryContainer: CouleursApplication.secondaireFonce,
        surface: const Color(0xFF1E1E1E),
        error: CouleursApplication.erreur,
        onPrimary: CouleursApplication.texteSurPrimaire,
        onSecondary: CouleursApplication.texteSurPrimaire,
        onSurface: const Color(0xFFE0E0E0),
        onError: CouleursApplication.texteSurPrimaire,
      ),
      
      // Typographie
      textTheme: _construireTextThemeSombre(),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Cartes
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonGrand),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApplication.primaire,
          foregroundColor: CouleursApplication.texteSurPrimaire,
          elevation: 4,
          shadowColor: CouleursApplication.primaire.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rayonMoyen),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CouleursApplication.primaire,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.primaire,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.erreur,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
          borderSide: const BorderSide(
            color: CouleursApplication.erreur,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: espaceMoyen,
          vertical: espaceMoyen,
        ),
        hintStyle: TextStyle(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: CouleursApplication.primaire,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CouleursApplication.primaire,
        foregroundColor: CouleursApplication.texteSurPrimaire,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonMoyen),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: const Color(0xFFE0E0E0).withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CouleursApplication.primaire,
        linearTrackColor: Color(0xFF1E1E1E),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        contentTextStyle: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonPetit),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayonGrand),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
        ),
      ),
    );
  }
  
  // ── Construction du TextTheme ──
  static TextTheme _construireTextTheme() {
    final textThemeBase = GoogleFonts.poppinsTextTheme();
    
    return textThemeBase.copyWith(
      // Titres
      displayLarge: textThemeBase.displayLarge?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: textThemeBase.displayMedium?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: textThemeBase.displaySmall?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.3,
      ),
      
      // Titres de section
      headlineLarge: textThemeBase.headlineLarge?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      headlineMedium: textThemeBase.headlineMedium?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      headlineSmall: textThemeBase.headlineSmall?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      
      // Titres de carte
      titleLarge: textThemeBase.titleLarge?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: textThemeBase.titleMedium?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: textThemeBase.titleSmall?.copyWith(
        color: CouleursApplication.texteSecondaire,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      
      // Corps de texte
      bodyLarge: textThemeBase.bodyLarge?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: textThemeBase.bodyMedium?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: textThemeBase.bodySmall?.copyWith(
        color: CouleursApplication.texteSecondaire,
        fontSize: 12,
        height: 1.4,
      ),
      
      // Labels
      labelLarge: textThemeBase.labelLarge?.copyWith(
        color: CouleursApplication.textePrincipal,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: textThemeBase.labelMedium?.copyWith(
        color: CouleursApplication.texteSecondaire,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: textThemeBase.labelSmall?.copyWith(
        color: CouleursApplication.texteClair,
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    );
  }
  
  // ── Construction du TextTheme sombre ──
  static TextTheme _construireTextThemeSombre() {
    final textThemeBase = GoogleFonts.poppinsTextTheme();
    
    return textThemeBase.copyWith(
      // Titres
      displayLarge: textThemeBase.displayLarge?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: textThemeBase.displayMedium?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: textThemeBase.displaySmall?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.3,
      ),
      
      // Titres de section
      headlineLarge: textThemeBase.headlineLarge?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      headlineMedium: textThemeBase.headlineMedium?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      headlineSmall: textThemeBase.headlineSmall?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      
      // Titres de carte
      titleLarge: textThemeBase.titleLarge?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: textThemeBase.titleMedium?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: textThemeBase.titleSmall?.copyWith(
        color: const Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      
      // Corps de texte
      bodyLarge: textThemeBase.bodyLarge?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: textThemeBase.bodyMedium?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: textThemeBase.bodySmall?.copyWith(
        color: const Color(0xFF9E9E9E),
        fontSize: 12,
        height: 1.4,
      ),
      
      // Labels
      labelLarge: textThemeBase.labelLarge?.copyWith(
        color: const Color(0xFFE0E0E0),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: textThemeBase.labelMedium?.copyWith(
        color: const Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: textThemeBase.labelSmall?.copyWith(
        color: const Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    );
  }
}
