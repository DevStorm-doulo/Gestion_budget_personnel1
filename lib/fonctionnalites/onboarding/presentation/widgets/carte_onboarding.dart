import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Widget CarteOnboarding - Présentation
// ─────────────────────────────────────────────
class CarteOnboarding extends StatelessWidget {
  final String titre;
  final String description;
  final IconData icone;
  final Color couleur;

  const CarteOnboarding({
    super.key,
    required this.titre,
    required this.description,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cercle coloré en arrière-plan
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icone,
                  size: 80,
                  color: couleur,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Titre
            Text(
              titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
