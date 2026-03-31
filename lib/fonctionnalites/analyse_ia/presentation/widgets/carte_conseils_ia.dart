import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/couleurs_application.dart';
import '../../../../core/theme/theme_application.dart';
import '../../../../core/widgets/effet_shimmer.dart';
import '../../domaine/entites/conseil_ia.dart';
import '../fournisseurs/fournisseur_analyse_ia.dart';
import '../../../authentification/presentation/fournisseurs/fournisseur_authentification.dart';

// ─────────────────────────────────────────────
// Widget Carte Conseils IA
// ─────────────────────────────────────────────
class CarteConseilsIA extends StatelessWidget {
  const CarteConseilsIA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FournisseurAnalyseIA>(
      builder: (context, fournisseur, child) {
        return Container(
          decoration: BoxDecoration(
            color: CouleursApplication.surface,
            borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
            boxShadow: ThemeApplication.ombreDouce,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _construireEntete(fournisseur),
              if (fournisseur.enChargement) ...[
                _construireShimmer(),
              ] else if (fournisseur.messageErreur != null) ...[
                _construireErreur(context, fournisseur),
              ] else if (fournisseur.conseils.isNotEmpty) ...[
                ...fournisseur.conseils.map(_construireConseil),
              ],
              _construireBoutonAnalyser(context, fournisseur),
              if (fournisseur.derniereAnalyse != null)
                _construireDateAnalyse(fournisseur.derniereAnalyse!),
            ],
          ),
        );
      },
    );
  }

  Widget _construireEntete(FournisseurAnalyseIA fournisseur) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espacePetite,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C4DFF),
                  Color(0xFF651FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(ThemeApplication.rayonMoyen),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: ThemeApplication.espacePetite),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conseils IA',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CouleursApplication.textePrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Gemini',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C4DFF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (fournisseur.enChargement) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireConseil(ConseilIA conseil) {
    final couleur = ConseilIA.couleurParCategorie(conseil.categorie);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeApplication.espaceMoyenne,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeApplication.espacePetite),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
          border: Border.all(
            color: couleur.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                conseil.icone,
                color: couleur,
                size: 18,
              ),
            ),
            const SizedBox(width: ThemeApplication.espacePetite),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conseil.titre,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CouleursApplication.textePrincipal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conseil.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: CouleursApplication.texteSecondaire,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeApplication.espaceMoyenne,
        vertical: 4,
      ),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EffetShimmer(
              enfant: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: CouleursApplication.surfaceAlt,
                  borderRadius:
                      BorderRadius.circular(ThemeApplication.rayonMoyen),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _construireErreur(
      BuildContext context, FournisseurAnalyseIA fournisseur) {
    return Padding(
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: CouleursApplication.erreur,
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          Text(
            fournisseur.messageErreur!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CouleursApplication.erreur,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          TextButton.icon(
            onPressed: () {
              final auth = Provider.of<FournisseurAuthentification>(
                  context,
                  listen: false);
              if (auth.utilisateur != null) {
                fournisseur.analyser(auth.utilisateur!.id);
              }
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonAnalyser(
      BuildContext context, FournisseurAnalyseIA fournisseur) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espacePetite,
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espacePetite,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7C4DFF),
              Color(0xFF651FFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
            onTap: fournisseur.enChargement
                ? null
                : () {
                    final auth = Provider.of<FournisseurAuthentification>(
                        context,
                        listen: false);
                    if (auth.utilisateur != null) {
                      fournisseur.analyser(auth.utilisateur!.id);
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (fournisseur.enChargement)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    fournisseur.enChargement
                        ? 'Analyse en cours...'
                        : 'Analyser mes dépenses',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construireDateAnalyse(DateTime date) {
    final dateFormatee = DateFormat('dd/MM/yyyy à HH:mm', 'fr').format(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThemeApplication.espaceMoyenne,
        0,
        ThemeApplication.espaceMoyenne,
        ThemeApplication.espacePetite,
      ),
      child: Text(
        'Dernière analyse : $dateFormatee',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: CouleursApplication.texteClair,
        ),
      ),
    );
  }
}
