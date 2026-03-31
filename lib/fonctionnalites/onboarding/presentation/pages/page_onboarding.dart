import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/services/service_preferences.dart';
import '../../../authentification/presentation/pages/page_connexion.dart';
import '../../domaine/entites/donnee_onboarding.dart';
import '../widgets/carte_onboarding.dart';

// ─────────────────────────────────────────────
// Page Onboarding - Présentation
// ─────────────────────────────────────────────
class PageOnboarding extends StatefulWidget {
  const PageOnboarding({super.key});

  @override
  State<PageOnboarding> createState() => _PageOnboardingState();
}

class _PageOnboardingState extends State<PageOnboarding> {
  final PageController _pageController = PageController();
  int _pageActuelle = 0;

  // Données des 4 écrans d'onboarding
  final List<DonneeOnboarding> _pages = [
    const DonneeOnboarding(
      titre: 'Bienvenue sur FlowCash',
      description: 'Gérez votre argent intelligemment et atteignez vos objectifs financiers',
      icone: Icons.account_balance_wallet_rounded,
      couleur: Color(0xFF6C63FF),
    ),
    const DonneeOnboarding(
      titre: 'Suivez vos dépenses',
      description: 'Enregistrez chaque transaction et visualisez où va votre argent',
      icone: Icons.track_changes_rounded,
      couleur: Color(0xFF2196F3),
    ),
    const DonneeOnboarding(
      titre: 'Budgets intelligents',
      description: 'Définissez des budgets par catégorie et recevez des alertes avant de dépasser',
      icone: Icons.pie_chart_rounded,
      couleur: Color(0xFF4CAF50),
    ),
    const DonneeOnboarding(
      titre: 'Conseils personnalisés',
      description: 'Notre IA analyse vos habitudes et vous guide vers une meilleure santé financière',
      icone: Icons.auto_awesome_rounded,
      couleur: Color(0xFFFF9800),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _terminerOnboarding() async {
    await ServicePreferences().sauvegarderOnboardingVu();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PageConnexion()),
      );
    }
  }

  void _pageSuivante() {
    if (_pageActuelle < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageCourante = _pages[_pageActuelle];
    
    return Scaffold(
      backgroundColor: pageCourante.couleur.withValues(alpha: 0.05),
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec indicateur de progression et bouton passer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicateur de progression textuel
                  Text(
                    '${_pageActuelle + 1}/${_pages.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // Bouton passer (sauf dernière page)
                  if (_pageActuelle < _pages.length - 1)
                    TextButton(
                      onPressed: _terminerOnboarding,
                      child: Text(
                        'Passer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Contenu principal avec PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _pageActuelle = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return CarteOnboarding(
                    titre: page.titre,
                    description: page.description,
                    icone: page.icone,
                    couleur: page.couleur,
                  );
                },
              ),
            ),
            
            // Indicateur de page et bouton d'action
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // SmoothPageIndicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: pageCourante.couleur,
                      dotColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _pageActuelle < _pages.length - 1
                        ? OutlinedButton(
                            onPressed: _pageSuivante,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: pageCourante.couleur),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Suivant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: pageCourante.couleur,
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: _terminerOnboarding,
                            style: FilledButton.styleFrom(
                              backgroundColor: pageCourante.couleur,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Commencer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
}
