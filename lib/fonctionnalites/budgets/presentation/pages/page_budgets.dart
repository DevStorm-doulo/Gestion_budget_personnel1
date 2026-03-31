import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/couleurs_application.dart';
import '../../../../core/theme/theme_application.dart';
import '../../../../core/widgets/carte_degradee.dart';
import '../../../../core/widgets/barre_progression_budget.dart';
import '../../../../core/widgets/effet_shimmer.dart';
import '../../domaine/entites/budget.dart';
import '../fournisseurs/fournisseur_budget.dart';
import '../../../authentification/presentation/fournisseurs/fournisseur_authentification.dart';

// ─────────────────────────────────────────────
// Page d'affichage des budgets
// ─────────────────────────────────────────────
class PageBudgets extends StatefulWidget {
  const PageBudgets({Key? key}) : super(key: key);

  @override
  State<PageBudgets> createState() => _PageBudgetsState();
}

class _PageBudgetsState extends State<PageBudgets> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<FournisseurAuthentification>(context, listen: false);
      final fournisseurBudget = Provider.of<FournisseurBudget>(context, listen: false);
      if (auth.utilisateur != null) {
        fournisseurBudget.chargerBudgets(auth.utilisateur!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApplication.fond,
      appBar: AppBar(
        title: const Text(
          'Mes Budgets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: CouleursApplication.textePrincipal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CouleursApplication.textePrincipal),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: CouleursApplication.primaire),
            onPressed: () => _afficherDialogueAjoutBudget(),
          ),
        ],
      ),
      body: Consumer<FournisseurBudget>(
        builder: (context, fournisseur, child) {
          if (fournisseur.enChargement) {
            return const ShimmerListe(nombreElements: 5);
          }

          if (fournisseur.messageErreur != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ThemeApplication.espaceGrand),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 64, color: CouleursApplication.erreur),
                    const SizedBox(height: ThemeApplication.espaceMoyenne),
                    Text(
                      fournisseur.messageErreur!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: CouleursApplication.erreur, fontSize: 16),
                    ),
                    const SizedBox(height: ThemeApplication.espaceMoyenne),
                    ElevatedButton(
                      onPressed: () {
                        final auth = Provider.of<FournisseurAuthentification>(context, listen: false);
                        if (auth.utilisateur != null) {
                          fournisseur.chargerBudgets(auth.utilisateur!.id);
                        }
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (fournisseur.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: CouleursApplication.primaire.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        size: 44, color: CouleursApplication.primaire),
                  ),
                  const SizedBox(height: ThemeApplication.espaceMoyenne),
                  const Text('Aucun budget pour ce mois',
                      style: TextStyle(
                          color: CouleursApplication.texteSecondaire, fontSize: 16)),
                  const SizedBox(height: ThemeApplication.espacePetite),
                  const Text('Créez votre premier budget pour commencer',
                      style: TextStyle(
                          color: CouleursApplication.texteClair, fontSize: 14)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carte récapitulatif
                _carteRecapitulatif(fournisseur),
                const SizedBox(height: ThemeApplication.espaceGrand),

                // Liste des budgets
                _enteteSection('Budgets du mois'),
                const SizedBox(height: ThemeApplication.espaceMoyenne),
                ...fournisseur.budgets.map((budget) => Padding(
                  padding: const EdgeInsets.only(bottom: ThemeApplication.espacePetite),
                  child: BarreProgressionBudget(
                    montantDepense: budget.montantDepense,
                    montantLimite: budget.montantLimite,
                    nomCategorie: budget.nomCategorie,
                    icone: _iconePourCategorie(budget.nomCategorie),
                    onTap: () => _afficherDialogueModifierBudget(budget),
                  ),
                )),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _carteRecapitulatif(FournisseurBudget fournisseur) {
    return CarteDegradee.principale(
      enfant: Column(
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _elementRecapitulatif(
                'Total Limites',
                fournisseur.totalLimites,
                Icons.account_balance_wallet_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _elementRecapitulatif(
                'Total Dépensé',
                fournisseur.totalDepenses,
                Icons.shopping_cart_rounded,
              ),
            ],
          ),
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          // Barre de progression globale
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fournisseur.pourcentageGlobal.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CouleursApplication.couleurProgression(fournisseur.pourcentageGlobal),
                  borderRadius: BorderRadius.circular(ThemeApplication.rayonCercle),
                ),
              ),
            ),
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          Text(
            '${(fournisseur.pourcentageGlobal * 100).toStringAsFixed(0)}% du budget utilisé',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementRecapitulatif(String label, double montant, IconData icone) {
    return Column(
      children: [
        Icon(icone, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formaterMontant(montant)} FCFA',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _enteteSection(String titre) {
    return Text(
      titre,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: CouleursApplication.textePrincipal,
      ),
    );
  }

  IconData _iconePourCategorie(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'alimentation':
        return Icons.restaurant_rounded;
      case 'loyer':
        return Icons.home_rounded;
      case 'loisirs':
        return Icons.sports_esports_rounded;
      case 'sante':
        return Icons.local_hospital_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _afficherDialogueAjoutBudget() {
    final TextEditingController categorieController = TextEditingController();
    final TextEditingController montantController = TextEditingController();
    final fournisseurBudget = Provider.of<FournisseurBudget>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categorieController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  hintText: 'Ex: Alimentation, Transport...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: ThemeApplication.espaceMoyenne),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant limite (FCFA)',
                  hintText: 'Ex: 50000',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (categorieController.text.isNotEmpty && montantController.text.isNotEmpty) {
                final montant = double.tryParse(montantController.text);
                if (montant != null && montant > 0) {
                  final auth = Provider.of<FournisseurAuthentification>(context, listen: false);
                  if (auth.utilisateur != null) {
                    final nouveauBudget = Budget(
                      id: '',
                      categorieId: categorieController.text.toLowerCase(),
                      nomCategorie: categorieController.text,
                      montantLimite: montant,
                      montantDepense: 0.0,
                      mois: fournisseurBudget.moisSelectionne,
                      annee: fournisseurBudget.anneeSelectionnee,
                      dateCreation: DateTime.now(),
                    );
                    
                    final succes = await fournisseurBudget.ajouterBudget(
                      auth.utilisateur!.id,
                      nouveauBudget,
                    );
                    
                    if (succes && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget ajouté avec succès'),
                          backgroundColor: CouleursApplication.succes,
                        ),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _afficherDialogueModifierBudget(Budget budget) {
    final TextEditingController categorieController = TextEditingController(text: budget.nomCategorie);
    final TextEditingController montantController = TextEditingController(text: budget.montantLimite.toString());
    final fournisseurBudget = Provider.of<FournisseurBudget>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categorieController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  hintText: 'Ex: Alimentation, Transport...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: ThemeApplication.espaceMoyenne),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant limite (FCFA)',
                  hintText: 'Ex: 50000',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (categorieController.text.isNotEmpty && montantController.text.isNotEmpty) {
                final montant = double.tryParse(montantController.text);
                if (montant != null && montant > 0) {
                  final auth = Provider.of<FournisseurAuthentification>(context, listen: false);
                  if (auth.utilisateur != null) {
                    final budgetModifie = budget.copyWith(
                      categorieId: categorieController.text.toLowerCase(),
                      nomCategorie: categorieController.text,
                      montantLimite: montant,
                      dateModification: DateTime.now(),
                    );
                    
                    final succes = await fournisseurBudget.modifierBudget(
                      auth.utilisateur!.id,
                      budgetModifie,
                    );
                    
                    if (succes && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget modifié avec succès'),
                          backgroundColor: CouleursApplication.succes,
                        ),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  String _formaterMontant(double montant) {
    final n = montant.abs().toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
