import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fournisseurs/fournisseur_authentification.dart';
import '../../../tableau_de_bord/presentation/pages/page_tableau_bord.dart';
import 'page_connexion.dart';

// ─────────────────────────────────────────────
// Page de démarrage avec authentification biométrique
// ─────────────────────────────────────────────
class PageDemarrage extends StatefulWidget {
  const PageDemarrage({super.key});

  @override
  State<PageDemarrage> createState() => _PageDemarrageState();
}

class _PageDemarrageState extends State<PageDemarrage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation pulse
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Lancer l'authentification biométrique après 500ms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _lancerAuthentificationBiometrique();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _lancerAuthentificationBiometrique() async {
    final fournisseurAuth = context.read<FournisseurAuthentification>();
    final succes = await fournisseurAuth.authentifierBiometrie();
    
    if (!mounted) return;
    
    if (succes) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PageTableauBord()),
      );
    } else {
      final messageErreur = fournisseurAuth.messageErreur ?? 'Authentification echouee';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageErreur),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _naviguerVersConnexion() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PageConnexion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo FlowCash
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_balance_wallet,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            
            const SizedBox(height: 60),
            
            // Icône fingerprint avec animation pulse
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.fingerprint,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Texte instruction
            Text(
              'Appuyez pour vous identifier',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            
            const SizedBox(height: 100),
            
            // Bouton utiliser mot de passe
            TextButton(
              onPressed: _naviguerVersConnexion,
              child: Text(
                'Utiliser mot de passe',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
