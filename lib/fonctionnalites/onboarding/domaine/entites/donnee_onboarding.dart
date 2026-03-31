import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Entité DonneeOnboarding - Domaine
// ─────────────────────────────────────────────
class DonneeOnboarding {
  final String titre;
  final String description;
  final IconData icone;
  final Color couleur;

  const DonneeOnboarding({
    required this.titre,
    required this.description,
    required this.icone,
    required this.couleur,
  });
}
