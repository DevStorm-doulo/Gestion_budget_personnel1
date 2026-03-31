import 'package:flutter/material.dart';
import '../theme/couleurs_application.dart';
import '../theme/theme_application.dart';

// ─────────────────────────────────────────────
// Widget barre de progression pour les budgets
// ─────────────────────────────────────────────
class BarreProgressionBudget extends StatelessWidget {
  final double montantDepense;
  final double montantLimite;
  final String nomCategorie;
  final IconData? icone;
  final Color? couleurPersonnalisee;
  final bool avecAnimation;
  final VoidCallback? onTap;
  
  const BarreProgressionBudget({
    Key? key,
    required this.montantDepense,
    required this.montantLimite,
    required this.nomCategorie,
    this.icone,
    this.couleurPersonnalisee,
    this.avecAnimation = true,
    this.onTap,
  }) : super(key: key);
  
  /// Retourne le pourcentage de consommation (0.0 à 1.0+)
  double get pourcentage {
    if (montantLimite <= 0) return 0;
    return (montantDepense / montantLimite).clamp(0.0, 1.0);
  }
  
  /// Retourne le pourcentage formaté en pourcentage
  String get pourcentageFormate => '${(pourcentage * 100).toStringAsFixed(0)}%';
  
  /// Retourne la couleur selon le pourcentage
  Color get couleur {
    if (couleurPersonnalisee != null) return couleurPersonnalisee!;
    return CouleursApplication.couleurProgression(pourcentage);
  }
  
  /// Retourne le dégradé selon le pourcentage
  LinearGradient get degrade {
    return CouleursApplication.degradeProgression(pourcentage);
  }
  
  /// Vérifie si le budget est dépassé
  bool get estDepasse => montantDepense > montantLimite;
  
  /// Vérifie si le budget est en alerte (> 80%)
  bool get estEnAlerte => pourcentage >= 0.8 && !estDepasse;
  
  /// Retourne le montant restant
  double get montantRestant => (montantLimite - montantDepense).clamp(0, double.infinity);
  
  @override
  Widget build(BuildContext context) {
    final contenu = Container(
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyen),
      decoration: BoxDecoration(
        color: CouleursApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
        boxShadow: ThemeApplication.ombreDouce,
        border: estEnAlerte
            ? Border.all(
                color: CouleursApplication.avertissement.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône, nom et pourcentage
          _construireEnTete(),
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          
          // Barre de progression
          _construireBarreProgression(),
          const SizedBox(height: ThemeApplication.espacePetite),
          
          // Informations financières
          _construireInformations(),
          
          // Alerte si nécessaire
          if (estEnAlerte) ...[
            const SizedBox(height: ThemeApplication.espacePetite),
            _construireAlerte(),
          ],
        ],
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: contenu);
    }
    
    return contenu;
  }
  
  Widget _construireEnTete() {
    return Row(
      children: [
        // Icône avec fond coloré
        if (icone != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ThemeApplication.rayonPetit),
            ),
            child: Icon(
              icone,
              color: couleur,
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeApplication.espacePetite),
        ],
        
        // Nom de la catégorie
        Expanded(
          child: Text(
            nomCategorie,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CouleursApplication.textePrincipal,
            ),
          ),
        ),
        
        // Pourcentage
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
          ),
          child: Text(
            pourcentageFormate,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _construireBarreProgression() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeurMax = constraints.maxWidth;
        final largeurProgression = largeurMax * pourcentage.clamp(0.0, 1.0);
        
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: CouleursApplication.surfaceAlt,
            borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
          ),
          child: Stack(
            children: [
              // Barre de progression avec dégradé
              if (avecAnimation)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: largeurProgression),
                  duration: ThemeApplication.animationLente,
                  curve: ThemeApplication.courbeAnimation,
                  builder: (context, valeur, child) {
                    return _construireBarreAvecLargeur(valeur);
                  },
                )
              else
                _construireBarreAvecLargeur(largeurProgression),
            ],
          ),
        );
      },
    );
  }
  
  Widget _construireBarreAvecLargeur(double largeur) {
    return Container(
      width: largeur,
      decoration: BoxDecoration(
        gradient: degrade,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
  
  Widget _construireInformations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Montant dépensé
        Text(
          '${_formaterMontant(montantDepense)} FCFA',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: estDepasse ? CouleursApplication.erreur : CouleursApplication.textePrincipal,
          ),
        ),
        
        // Séparateur
        Text(
          '/',
          style: TextStyle(
            fontSize: 13,
            color: CouleursApplication.texteClair,
          ),
        ),
        
        // Montant limite
        Text(
          '${_formaterMontant(montantLimite)} FCFA',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: CouleursApplication.texteSecondaire,
          ),
        ),
      ],
    );
  }
  
  Widget _construireAlerte() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CouleursApplication.avertissementClair,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonPetit),
        border: Border.all(
          color: CouleursApplication.avertissement.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: CouleursApplication.avertissement,
            size: 16,
          ),
          const SizedBox(width: ThemeApplication.espacePetite),
          Expanded(
            child: Text(
              'Budget bientôt atteint ! Il reste ${_formaterMontant(montantRestant)} FCFA',
              style: const TextStyle(
                fontSize: 12,
                color: CouleursApplication.avertissement,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formaterMontant(double montant) {
    final n = montant.abs().toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ─────────────────────────────────────────────
// Widget compact pour afficher un budget
// ─────────────────────────────────────────────
class BudgetCompact extends StatelessWidget {
  final String nomCategorie;
  final double montantDepense;
  final double montantLimite;
  final IconData icone;
  final Color couleur;
  final VoidCallback? onTap;
  
  const BudgetCompact({
    Key? key,
    required this.nomCategorie,
    required this.montantDepense,
    required this.montantLimite,
    required this.icone,
    required this.couleur,
    this.onTap,
  }) : super(key: key);
  
  double get pourcentage {
    if (montantLimite <= 0) return 0;
    return (montantDepense / montantLimite).clamp(0.0, 1.0);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeApplication.espaceMoyen),
        decoration: BoxDecoration(
          color: CouleursApplication.surface,
          borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
          boxShadow: ThemeApplication.ombreDouce,
        ),
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(ThemeApplication.rayonPetit),
              ),
              child: Icon(icone, color: couleur, size: 22),
            ),
            const SizedBox(width: ThemeApplication.espaceMoyenne),
            
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomCategorie,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CouleursApplication.textePrincipal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formaterMontant(montantDepense)} / ${_formaterMontant(montantLimite)} FCFA',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CouleursApplication.texteSecondaire,
                    ),
                  ),
                ],
              ),
            ),
            
            // Pourcentage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CouleursApplication.couleurProgression(pourcentage)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
              ),
              child: Text(
                '${(pourcentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CouleursApplication.couleurProgression(pourcentage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formaterMontant(double montant) {
    final n = montant.abs().toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
