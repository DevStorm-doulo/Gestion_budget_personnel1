import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domaine/entites/transaction.dart';
import '../fournisseurs/fournisseur_transaction.dart';
import '../../../tableau_de_bord/presentation/fournisseurs/fournisseur_tableau_bord.dart';
import '../../../../core/utilitaires/constantes.dart';
import 'package:intl/intl.dart';

class PageAjoutTransaction extends StatefulWidget {
  const PageAjoutTransaction({super.key});

  @override
  State<PageAjoutTransaction> createState() => _PageAjoutTransactionState();
}

class _PageAjoutTransactionState extends State<PageAjoutTransaction> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _controleurMontant = TextEditingController();
  final _controleurDescription = TextEditingController();
  DateTime _dateSelectionnee = DateTime.now();
  String _typeSelectionne = 'expense';
  String _categorieSelectionnee = 'alimentation';

  final List<String> categoriesRevenus = ['salaire', 'bourse', 'aide', 'autre'];
  final List<String> categoriesDepenses = [
    'transport',
    'alimentation',
    'loyer',
    'loisirs',
    'sante',
    'autre'
  ];

  @override
  void dispose() {
    _controleurMontant.dispose();
    _controleurDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fournisseur = Provider.of<FournisseurTransaction>(context);
    final categories =
        _typeSelectionne == 'income' ? categoriesRevenus : categoriesDepenses;

    if (!categories.contains(_categorieSelectionnee)) {
      _categorieSelectionnee = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: CodeCouleurs.fond,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Marges.moyenne),
        child: Column(
          children: [
            // Sélecteur Type
            Container(
              decoration: BoxDecoration(
                color: CodeCouleurs.surface,
                borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
                boxShadow: DesignSystem.ombreDouce,
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _boutonType(
                    label: 'Dépense',
                    icone: Icons.arrow_upward_rounded,
                    actif: _typeSelectionne == 'expense',
                    couleur: CodeCouleurs.rouge,
                    onTap: () => setState(() => _typeSelectionne = 'expense'),
                  ),
                  _boutonType(
                    label: 'Revenu',
                    icone: Icons.arrow_downward_rounded,
                    actif: _typeSelectionne == 'income',
                    couleur: CodeCouleurs.vert,
                    onTap: () => setState(() => _typeSelectionne = 'income'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Marges.moyenne),

            // Formulaire
            Container(
              decoration: BoxDecoration(
                color: CodeCouleurs.surface,
                borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
                boxShadow: DesignSystem.ombreDouce,
              ),
              padding: const EdgeInsets.all(Marges.grande),
              child: Form(
                key: _cleFormulaire,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Montant
                    TextFormField(
                      controller: _controleurMontant,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: CodeCouleurs.textePrincipal),
                      decoration: InputDecoration(
                        labelText: 'Montant (FCFA)',
                        hintText: 'Ex: 25 000',
                        prefixIcon: const Icon(Icons.attach_money_rounded,
                            color: CodeCouleurs.primaire),
                        filled: true,
                        fillColor: CodeCouleurs.fond,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.rayonBordurePetit),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.rayonBordurePetit),
                          borderSide: const BorderSide(
                              color: CodeCouleurs.primaire, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Entrez un montant';
                        final montant = double.tryParse(v.replaceAll(' ', ''));
                        if (montant == null) {
                          return 'Nombre invalide';
                        }
                        if (montant <= 0) {
                          return 'Le montant doit être positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Marges.moyenne),

                    // Catégorie
                    DropdownButtonFormField<String>(
                      initialValue: _categorieSelectionnee,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(
                          iconeCategorie(_categorieSelectionnee),
                          color: couleurCategorie(_categorieSelectionnee),
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded,
                            color: CodeCouleurs.primaire),
                        filled: true,
                        fillColor: CodeCouleurs.fond,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.rayonBordurePetit),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.rayonBordurePetit),
                          borderSide: const BorderSide(
                              color: CodeCouleurs.primaire, width: 2),
                        ),
                      ),
                      items: categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Row(
                                  children: [
                                    Icon(iconeCategorie(cat),
                                        color: couleurCategorie(cat), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat[0].toUpperCase() + cat.substring(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _categorieSelectionnee = v!),
                    ),
                    const SizedBox(height: Marges.moyenne),

                    // Sélecteur de date
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateSelectionnee,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: CodeCouleurs.primaire),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null && mounted) {
                          setState(() => _dateSelectionnee = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Marges.moyenne, vertical: Marges.moyenne),
                        decoration: BoxDecoration(
                          color: CodeCouleurs.fond,
                          borderRadius: BorderRadius.circular(
                              DesignSystem.rayonBordurePetit),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: CodeCouleurs.primaire),
                            const SizedBox(width: Marges.moyenne),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date',
                                      style: TextStyle(
                                          color: CodeCouleurs.texteSecondaire,
                                          fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd MMMM yyyy', 'fr')
                                        .format(_dateSelectionnee),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: CodeCouleurs.textePrincipal),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: CodeCouleurs.texteSecondaire),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Marges.moyenne),

                    // Description
                    TextFormField(
                      controller: _controleurDescription,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (optionnelle)',
                        prefixIcon: const Icon(Icons.notes_rounded,
                            color: CodeCouleurs.primaire),
                        filled: true,
                        fillColor: CodeCouleurs.fond,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.rayonBordurePetit),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.rayonBordurePetit),
                          borderSide: const BorderSide(
                              color: CodeCouleurs.primaire, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: Marges.enorme),

                    // Bouton Enregistrer
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: fournisseur.enChargement
                            ? null
                            : () async {
                                if (_cleFormulaire.currentState!.validate()) {
                                  final nav = Navigator.of(context);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text('Erreur: Utilisateur non connecté')),
                                    );
                                    return;
                                  }

                                  try {
                                    final montantTexte = _controleurMontant.text
                                        .replaceAll(' ', '');
                                    final montant = double.parse(montantTexte);

                                    // Vérification: les nombres négatifs ne sont pas autorisés
                                    if (montant <= 0) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                            content: Text('Le montant doit être positif')),
                                      );
                                      return;
                                    }

                                    // Vérification: nouveau utilisateur doit d'abord ajouter un revenu
                                    if (_typeSelectionne == 'expense') {
                                      // Charger les données du tableau de bord pour vérifier
                                      final tableauBord = Provider.of<FournisseurTableauBord>(
                                          context,
                                          listen: false);
                                      
                                      await tableauBord.chargerDonnees();
                                      
                                      // Vérifier si l'utilisateur a déjà des revenus
                                      final transactions = fournisseur.transactions;
                                      final aDesRevenus = transactions.any((t) => t.type == 'income');
                                      
                                      if (!aDesRevenus) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                              content: Text('Vous devez d\'abord ajouter un revenu avant d\'ajouter une dépense')),
                                        );
                                        return;
                                      }

                                      // Vérification: les dépenses ne doivent pas dépasser le revenu
                                      if (tableauBord.soldeActuel < montant) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                              content: Text('Solde insuffisant! Votre solde actuel est de ${formatFCFA(tableauBord.soldeActuel)} FCA')),
                                        );
                                        return;
                                      }
                                    }

                                    final nouvelleTransaction = TransactionEntity(
                                      id: '',
                                      userId: user.uid,
                                      type: _typeSelectionne,
                                      amount: montant,
                                      date: _dateSelectionnee,
                                      category: _categorieSelectionnee,
                                      description:
                                          _controleurDescription.text.isEmpty
                                              ? null
                                              : _controleurDescription.text,
                                      createdAt: DateTime.now(),
                                    );

                                    final succes = await fournisseur
                                        .ajouterTransaction(nouvelleTransaction);
                                    if (!mounted) return;
                                    if (succes) {
                                      nav.pop();
                                    } else if (fournisseur.messageErreur != null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                            content: Text(fournisseur.messageErreur!)),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Erreur inattendue: $e')),
                                    );
                                  }
                                }
                              },
                        child: fournisseur.enChargement
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Enregistrer',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _boutonType({
    required String label,
    required IconData icone,
    required bool actif,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: actif ? couleur : Colors.transparent,
            borderRadius:
                BorderRadius.circular(DesignSystem.rayonBordurePetit),
            boxShadow: actif ? DesignSystem.ombreDouce : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone,
                  color: actif ? Colors.white : CodeCouleurs.texteSecondaire,
                  size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: actif ? Colors.white : CodeCouleurs.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
