import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fournisseurs/fournisseur_authentification.dart';
import '../widgets/champ_texte_personnalise.dart';
import '../../../../core/utilitaires/constantes.dart';

class PageInscription extends StatefulWidget {
  const PageInscription({super.key});

  @override
  State<PageInscription> createState() => _PageInscriptionState();
}

class _PageInscriptionState extends State<PageInscription> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurNom = TextEditingController();
  final _controleurEmail = TextEditingController();
  final _controleurMotDePasse = TextEditingController();

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurEmail.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurAuth = Provider.of<FournisseurAuthentification>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.degradePrimaire),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Marges.grande),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut)),
                child: Padding(
                  padding: const EdgeInsets.all(Marges.enorme),
                  child: Form(
                    key: _cleFormulaire,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icône d'en-tête
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: DesignSystem.degradePrimaire,
                            shape: BoxShape.circle,
                            boxShadow: DesignSystem.ombreColoree,
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              size: 38, color: Colors.white),
                        ),
                        const SizedBox(height: Marges.grande),
                        const Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: CodeCouleurs.textePrincipal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Rejoignez-nous pour gérer votre budget',
                          style: TextStyle(fontSize: 14, color: CodeCouleurs.texteSecondaire),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Marges.enorme),

                        // Champs
                        ChampTextePersonnalise(
                          controleur: _controleurNom,
                          libelle: 'Nom complet',
                          icone: Icons.person_outline_rounded,
                          validateur: (v) => v!.isEmpty ? 'Entrez votre nom' : null,
                        ),
                        const SizedBox(height: Marges.moyenne),
                        ChampTextePersonnalise(
                          controleur: _controleurEmail,
                          libelle: 'Adresse email',
                          icone: Icons.alternate_email_rounded,
                          typeClavier: TextInputType.emailAddress,
                          validateur: (v) =>
                              v!.isEmpty || !v.contains('@') ? 'Email invalide' : null,
                        ),
                        const SizedBox(height: Marges.moyenne),
                        ChampTextePersonnalise(
                          controleur: _controleurMotDePasse,
                          libelle: 'Mot de passe',
                          icone: Icons.lock_outline_rounded,
                          estMotDePasse: true,
                          validateur: (v) =>
                              v!.length < 6 ? 'Minimum 6 caractères' : null,
                        ),
                        const SizedBox(height: Marges.moyenne),

                        // Message d'erreur
                        if (fournisseurAuth.messageErreur != null) ...[
                          Container(
                            padding: const EdgeInsets.all(Marges.moyenne),
                            decoration: BoxDecoration(
                              color: CodeCouleurs.rouge.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                              border: Border.all(
                                  color: CodeCouleurs.rouge.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: CodeCouleurs.rouge, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fournisseurAuth.messageErreur!,
                                    style: const TextStyle(
                                        color: CodeCouleurs.rouge,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Marges.moyenne),
                        ],

                        // Bouton inscription
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: fournisseurAuth.enChargement
                                ? null
                                : () async {
                                    if (_cleFormulaire.currentState!.validate()) {
                                      final succes = await fournisseurAuth.sInscrire(
                                        _controleurEmail.text.trim(),
                                        _controleurMotDePasse.text.trim(),
                                        _controleurNom.text.trim(),
                                      );
                                      if (succes && mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                            child: fournisseurAuth.enChargement
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : const Text('Créer mon compte',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: Marges.moyenne),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                              foregroundColor: CodeCouleurs.texteSecondaire),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Déjà un compte ? ',
                              children: [
                                TextSpan(
                                  text: 'Se connecter',
                                  style: TextStyle(
                                      color: CodeCouleurs.primaire,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
