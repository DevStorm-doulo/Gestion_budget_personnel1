import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/couleurs_application.dart';
import '../theme/theme_application.dart';
import '../utilitaires/formateur_montant.dart';
import '../../fonctionnalites/devises/presentation/fournisseurs/fournisseur_devise.dart';

// ─────────────────────────────────────────────
// Widget Carte avec dégradé premium
// ─────────────────────────────────────────────
class CarteDegradee extends StatelessWidget {
  final LinearGradient? degrade;
  final Widget enfant;
  final EdgeInsetsGeometry? marge;
  final EdgeInsetsGeometry? remplissage;
  final List<BoxShadow>? ombre;
  final double? rayonBordure;
  final VoidCallback? onTap;
  final bool avecAnimation;
  
  const CarteDegradee({
    Key? key,
    required this.enfant,
    this.degrade,
    this.marge,
    this.remplissage,
    this.ombre,
    this.rayonBordure,
    this.onTap,
    this.avecAnimation = true,
  }) : super(key: key);
  
  /// Constructeur pour carte principale (solde)
  factory CarteDegradee.principale({
    required Widget enfant,
    EdgeInsetsGeometry? marge,
    EdgeInsetsGeometry? remplissage,
    VoidCallback? onTap,
  }) {
    return CarteDegradee(
      degrade: CouleursApplication.degradePremium,
      ombre: ThemeApplication.ombreColoree,
      rayonBordure: ThemeApplication.rayonGrand,
      marge: marge,
      remplissage: remplissage ?? const EdgeInsets.symmetric(
        vertical: ThemeApplication.espaceTresGrand,
        horizontal: ThemeApplication.espaceGrand,
      ),
      onTap: onTap,
      enfant: enfant,
    );
  }
  
  /// Constructeur pour carte de statistique
  factory CarteDegradee.statistique({
    required Widget enfant,
    required Color couleur,
    EdgeInsetsGeometry? marge,
    VoidCallback? onTap,
  }) {
    return CarteDegradee(
      ombre: [
        BoxShadow(
          color: couleur.withValues(alpha: 0.2),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
      rayonBordure: ThemeApplication.rayonGrand,
      marge: marge,
      remplissage: const EdgeInsets.all(ThemeApplication.espaceMoyen),
      onTap: onTap,
      enfant: enfant,
    );
  }
  
  /// Constructeur pour carte de revenu
  factory CarteDegradee.revenu({
    required Widget enfant,
    EdgeInsetsGeometry? marge,
    VoidCallback? onTap,
  }) {
    return CarteDegradee.statistique(
      couleur: CouleursApplication.succes,
      marge: marge,
      onTap: onTap,
      enfant: enfant,
    );
  }
  
  /// Constructeur pour carte de dépense
  factory CarteDegradee.depense({
    required Widget enfant,
    EdgeInsetsGeometry? marge,
    VoidCallback? onTap,
  }) {
    return CarteDegradee.statistique(
      couleur: CouleursApplication.erreur,
      marge: marge,
      onTap: onTap,
      enfant: enfant,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: degrade,
      color: degrade == null ? CouleursApplication.surface : null,
      borderRadius: BorderRadius.circular(
        rayonBordure ?? ThemeApplication.rayonGrand,
      ),
      boxShadow: ombre ?? ThemeApplication.ombreDouce,
    );
    
    final contenu = Container(
      decoration: decoration,
      padding: remplissage,
      margin: marge,
      child: enfant,
    );
    
    if (onTap != null) {
      return avecAnimation
          ? _construireAvecAnimation(contenu)
          : GestureDetector(onTap: onTap, child: contenu);
    }
    
    return contenu;
  }
  
  Widget _construireAvecAnimation(Widget contenu) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: ThemeApplication.animationMoyenne,
      curve: ThemeApplication.courbeAnimation,
      builder: (context, valeur, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * valeur),
          child: Opacity(
            opacity: valeur,
            child: child,
          ),
        );
      },
      child: contenu,
    );
  }
}

// ─────────────────────────────────────────────
// Widget pour afficher un montant avec style
// ─────────────────────────────────────────────
class MontantStylise extends StatelessWidget {
  final double montant;
  final String? prefixe;
  final String? suffixe;
  final Color? couleur;
  final double taillePolice;
  final bool avecAnimation;
  
  const MontantStylise({
    Key? key,
    required this.montant,
    this.prefixe,
    this.suffixe = 'FCFA',
    this.couleur,
    this.taillePolice = 36,
    this.avecAnimation = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final texte = '${prefixe ?? ''}${_formaterMontant(context, montant)} ${suffixe ?? ''}';
    
    if (!avecAnimation) {
      return Text(
        texte,
        style: TextStyle(
          color: couleur ?? CouleursApplication.texteSurPrimaire,
          fontSize: taillePolice,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      );
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: montant),
      duration: ThemeApplication.animationLente,
      curve: ThemeApplication.courbeAnimation,
      builder: (context, valeur, child) {
        return Text(
          '${prefixe ?? ''}${_formaterMontant(context, valeur)} ${suffixe ?? ''}',
          style: TextStyle(
            color: couleur ?? CouleursApplication.texteSurPrimaire,
            fontSize: taillePolice,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }
  
  String _formaterMontant(BuildContext context, double montant) {
    final fournisseurDevise = Provider.of<FournisseurDevise>(context, listen: false);
    return FormateurMontant.formater(montant, fournisseurDevise.deviseActive);
  }
}

// ─────────────────────────────────────────────
// Widget pour icône avec fond coloré
// ─────────────────────────────────────────────
class IconeAvecFond extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final double taille;
  final double tailleIcone;
  
  const IconeAvecFond({
    Key? key,
    required this.icone,
    required this.couleur,
    this.taille = 40,
    this.tailleIcone = 20,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icone,
        color: couleur,
        size: tailleIcone,
      ),
    );
  }
}
