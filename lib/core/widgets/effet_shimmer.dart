import 'package:flutter/material.dart';
import '../theme/couleurs_application.dart';
import '../theme/theme_application.dart';

// ─────────────────────────────────────────────
// Widget effet shimmer pour le chargement
// ─────────────────────────────────────────────
class EffetShimmer extends StatefulWidget {
  final Widget enfant;
  final bool actif;
  final Color? couleurBase;
  final Color? couleurBrillance;
  
  const EffetShimmer({
    Key? key,
    required this.enfant,
    this.actif = true,
    this.couleurBase,
    this.couleurBrillance,
  }) : super(key: key);
  
  @override
  State<EffetShimmer> createState() => _EffetShimmerState();
}

class _EffetShimmerState extends State<EffetShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleur;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controleur, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.actif) return widget.enfant;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.couleurBase ?? CouleursApplication.surfaceAlt,
                widget.couleurBrillance ?? CouleursApplication.surface,
                widget.couleurBase ?? CouleursApplication.surfaceAlt,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.enfant,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  
  const _SlidingGradientTransform({required this.slidePercent});
  
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * slidePercent,
      0.0,
      0.0,
    );
  }
}

// ─────────────────────────────────────────────
// Widget placeholder shimmer pour les cartes
// ─────────────────────────────────────────────
class ShimmerCarte extends StatelessWidget {
  final double hauteur;
  final double largeur;
  final double rayonBordure;
  
  const ShimmerCarte({
    Key? key,
    this.hauteur = 100,
    this.largeur = double.infinity,
    this.rayonBordure = 20,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EffetShimmer(
      enfant: Container(
        height: hauteur,
        width: largeur,
        decoration: BoxDecoration(
          color: CouleursApplication.surfaceAlt,
          borderRadius: BorderRadius.circular(rayonBordure),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget placeholder shimmer pour le texte
// ─────────────────────────────────────────────
class ShimmerTexte extends StatelessWidget {
  final double largeur;
  final double hauteur;
  final double rayonBordure;
  
  const ShimmerTexte({
    Key? key,
    this.largeur = 100,
    this.hauteur = 16,
    this.rayonBordure = 8,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EffetShimmer(
      enfant: Container(
        width: largeur,
        height: hauteur,
        decoration: BoxDecoration(
          color: CouleursApplication.surfaceAlt,
          borderRadius: BorderRadius.circular(rayonBordure),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget placeholder shimmer pour le dashboard
// ─────────────────────────────────────────────
class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte solde shimmer
          const ShimmerCarte(hauteur: 180),
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          
          // Cartes revenus/dépenses shimmer
          Row(
            children: [
              Expanded(
                child: ShimmerCarte(
                  hauteur: 120,
                  rayonBordure: ThemeApplication.rayonGrand,
                ),
              ),
              const SizedBox(width: ThemeApplication.espaceMoyenne),
              Expanded(
                child: ShimmerCarte(
                  hauteur: 120,
                  rayonBordure: ThemeApplication.rayonGrand,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeApplication.espaceGrand),
          
          // Graphique shimmer
          ShimmerCarte(
            hauteur: 250,
            rayonBordure: ThemeApplication.rayonGrand,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget placeholder shimmer pour liste
// ─────────────────────────────────────────────
class ShimmerListe extends StatelessWidget {
  final int nombreElements;
  
  const ShimmerListe({
    Key? key,
    this.nombreElements = 5,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nombreElements,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeApplication.espacePetite),
          child: EffetShimmer(
            enfant: Container(
              height: 80,
              decoration: BoxDecoration(
                color: CouleursApplication.surfaceAlt,
                borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
              ),
            ),
          ),
        );
      },
    );
  }
}
