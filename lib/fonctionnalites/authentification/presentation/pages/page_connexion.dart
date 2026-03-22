import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fournisseurs/fournisseur_authentification.dart';
import '../widgets/champ_texte_personnalise.dart';
import 'page_inscription.dart';
import '../../../../core/utilitaires/constantes.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> with SingleTickerProviderStateMixin {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurEmail = TextEditingController();
  final _controleurMotDePasse = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controleurEmail.dispose();
    _controleurMotDePasse.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurAuth = Provider.of<FournisseurAuthentification>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CodeCouleurs.primaire,
              CodeCouleurs.primaireFonce,
              CodeCouleurs.secondaireFonce,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Marges.grande),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.rayonBordureGrand),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(Marges.enorme + 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DesignSystem.rayonBordureGrand),
                          color: Colors.white,
                        ),
                        child: Form(
                          key: _cleFormulaire,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icône d'en-tête avec effet
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: CodeCouleurs.degradePrimaire,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: CodeCouleurs.primaire.withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded,
                                    size: 45, color: Colors.white),
                              ),
                              const SizedBox(height: Marges.grande + 8),
                              
                              // Titre avec style amélioré
                              ShaderMask(
                                shaderCallback: (bounds) => CodeCouleurs.degradePrimaire.createShader(bounds),
                                child: const Text(
                                  'Gestion Budget',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Connectez-vous pour gérer vos finances',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: CodeCouleurs.texteSecondaire,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Marges.enorme + 8),

                              // Champs avec style amélioré
                              Container(
                                decoration: BoxDecoration(
                                  color: CodeCouleurs.fond,
                                  borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                                ),
                                child: ChampTextePersonnalise(
                                  controleur: _controleurEmail,
                                  libelle: 'Adresse email',
                                  icone: Icons.alternate_email_rounded,
                                  typeClavier: TextInputType.emailAddress,
                                  validateur: (v) =>
                                      v!.isEmpty || !v.contains('@') ? 'Email invalide' : null,
                                ),
                              ),
                              const SizedBox(height: Marges.moyenne),
                              
                              Container(
                                decoration: BoxDecoration(
                                  color: CodeCouleurs.fond,
                                  borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                                ),
                                child: ChampTextePersonnalise(
                                  controleur: _controleurMotDePasse,
                                  libelle: 'Mot de passe',
                                  icone: Icons.lock_outline_rounded,
                                  estMotDePasse: true,
                                  validateur: (v) =>
                                      v!.length < 6 ? 'Minimum 6 caractères' : null,
                                ),
                              ),
                              const SizedBox(height: Marges.moyenne),

                              // Message d'erreur avec style amélioré
                              if (fournisseurAuth.messageErreur != null) ...[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(Marges.moyenne),
                                  decoration: BoxDecoration(
                                    color: CodeCouleurs.rougeClair,
                                    borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                                    border: Border.all(
                                        color: CodeCouleurs.rouge.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: CodeCouleurs.rouge, size: 20),
                                      const SizedBox(width: 10),
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

                              // Bouton connexion avec style amélioré
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: CodeCouleurs.degradePrimaire,
                                  borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CodeCouleurs.primaire.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
                                    ),
                                  ),
                                  onPressed: fournisseurAuth.enChargement
                                      ? null
                                      : () async {
                                          if (_cleFormulaire.currentState!.validate()) {
                                            await fournisseurAuth.seConnecter(
                                              _controleurEmail.text.trim(),
                                              _controleurMotDePasse.text.trim(),
                                            );
                                          }
                                        },
                                  child: fournisseurAuth.enChargement
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2.5))
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Se connecter',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_rounded, size: 20),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: Marges.grande),

                              // Lien inscription
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Pas encore de compte ? ',
                                    style: TextStyle(color: CodeCouleurs.texteSecondaire),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const PageInscription())),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => CodeCouleurs.degradePrimaire.createShader(bounds),
                                      child: const Text(
                                        'S\'inscrire',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
