import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domaine/entites/resultat_scan.dart';
import '../fournisseurs/fournisseur_transaction.dart';

// ─────────────────────────────────────────────
// Widget bouton pour scanner un reçu
// ─────────────────────────────────────────────
class BoutonScannerRecu extends StatelessWidget {
  final Function(ResultatScan) onResultatRecu;
  final Function(String) onErreur;

  const BoutonScannerRecu({
    super.key,
    required this.onResultatRecu,
    required this.onErreur,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _afficherBottomSheetSourceImage(context),
      icon: const Icon(Icons.document_scanner_rounded),
      label: const Text('Scanner un reçu'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _afficherBottomSheetSourceImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BottomSheetSourceImage(
        onResultatRecu: onResultatRecu,
        onErreur: onErreur,
      ),
    );
  }

}

// ─────────────────────────────────────────────
// BottomSheet pour choisir la source d'image
// ─────────────────────────────────────────────
class _BottomSheetSourceImage extends StatelessWidget {
  final Function(ResultatScan) onResultatRecu;
  final Function(String) onErreur;

  const _BottomSheetSourceImage({
    required this.onResultatRecu,
    required this.onErreur,
  });

  void _lancerAnalyse(BuildContext context, bool estCamera) async {
    final fournisseur = Provider.of<FournisseurTransaction>(context, listen: false);
    
    if (estCamera) {
      await fournisseur.analyserRecuDepuisCamera();
    } else {
      await fournisseur.analyserRecuDepuisGalerie();
    }
    
    if (!context.mounted) return;
    
    final resultat = fournisseur.dernierScan;
    final erreur = fournisseur.messageErreurScan;
    
    if (resultat != null) {
      onResultatRecu(resultat);
    } else if (erreur != null) {
      onErreur(erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Titre
          Text(
            'Comment souhaitez-vous scanner le reçu ?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Option caméra
          _OptionSource(
            icone: Icons.camera_alt_rounded,
            titre: 'Prendre une photo',
            description: 'Utilisez la caméra pour scanner le reçu',
            couleur: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.pop(context);
              _lancerAnalyse(context, true);
            },
          ),
          const SizedBox(height: 16),

          // Option galerie
          _OptionSource(
            icone: Icons.photo_library_rounded,
            titre: 'Choisir dans la galerie',
            description: 'Sélectionnez une photo existante',
            couleur: Theme.of(context).colorScheme.secondary,
            onTap: () {
              Navigator.pop(context);
              _lancerAnalyse(context, false);
            },
          ),
          const SizedBox(height: 24),

          // Bouton annuler
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget option de source d'image
// ─────────────────────────────────────────────
class _OptionSource extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String description;
  final Color couleur;
  final VoidCallback onTap;

  const _OptionSource({
    required this.icone,
    required this.titre,
    required this.description,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icone,
                color: couleur,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Overlay d'analyse en cours
// ─────────────────────────────────────────────
class OverlayAnalyse extends StatelessWidget {
  const OverlayAnalyse({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Analyse du reçu en cours...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Veuillez patienter',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
