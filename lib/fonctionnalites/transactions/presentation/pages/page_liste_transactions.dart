import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../fournisseurs/fournisseur_transaction.dart';
import '../../../../core/utilitaires/constantes.dart';
import '../../../devises/presentation/fournisseurs/fournisseur_devise.dart';
import '../../../../core/utilitaires/formateur_montant.dart';

class PageListeTransactions extends StatefulWidget {
  const PageListeTransactions({super.key});

  @override
  State<PageListeTransactions> createState() => _PageListeTransactionsState();
}

class _PageListeTransactionsState extends State<PageListeTransactions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FournisseurTransaction>(context, listen: false)
          .chargerTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FournisseurTransaction>(
      builder: (context, fournisseur, child) {
        if (fournisseur.enChargement && fournisseur.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: CodeCouleurs.primaire),
          );
        }

        if (fournisseur.messageErreur != null &&
            fournisseur.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Marges.grande),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 64, color: CodeCouleurs.texteSecondaire),
                  const SizedBox(height: Marges.moyenne),
                  Text(fournisseur.messageErreur!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: CodeCouleurs.rouge)),
                ],
              ),
            ),
          );
        }

        if (fournisseur.transactionsVisibles.isEmpty) {
          return _construireEtatVide();
        }

        // Message d'indication pour supprimer
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(Marges.moyenne),
              padding: const EdgeInsets.symmetric(
                  horizontal: Marges.moyenne, vertical: Marges.petite),
              decoration: BoxDecoration(
                color: CodeCouleurs.primaire.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(DesignSystem.rayonBordurePetit),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe_left_rounded,
                          color: CodeCouleurs.primaire, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Glissez vers la gauche pour masquer',
                        style: TextStyle(
                          color: CodeCouleurs.primaire,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: Marges.moyenne,
                    left: Marges.moyenne,
                    right: Marges.moyenne),
                itemCount: fournisseur.transactionsVisibles.length,
                itemBuilder: (context, index) {
                  final transaction = fournisseur.transactionsVisibles[index];
                  final estRevenu = transaction.type == 'income';
                  final couleur = couleurCategorie(transaction.category);
                  final icone = iconeCategorie(transaction.category);

                  return Dismissible(
                    key: Key(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin:
                          const EdgeInsets.symmetric(vertical: Marges.petite),
                      decoration: BoxDecoration(
                        color: CodeCouleurs.orange,
                        borderRadius: BorderRadius.circular(
                            DesignSystem.rayonBordurePetit),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: Marges.grande),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_off_rounded,
                              color: Colors.white, size: 24),
                          SizedBox(height: 4),
                          Text('Masquer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  DesignSystem.rayonBordureDefaut)),
                          title: const Text('Masquer la transaction',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text(
                              'Voulez-vous masquer cette transaction ?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: CodeCouleurs.orange),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Masquer'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      // Masquer la transaction (pas de suppression de la base de données)
                      fournisseur.masquerTransaction(transaction.id).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transaction masquée'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    DesignSystem.rayonBordurePetit)),
                            action: SnackBarAction(
                              label: 'Annuler',
                              onPressed: () {
                                fournisseur.afficherTransaction(transaction.id);
                              },
                            ),
                          ),
                        );
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: Marges.petite),
                      decoration: BoxDecoration(
                        color: CodeCouleurs.surface,
                        borderRadius: BorderRadius.circular(
                            DesignSystem.rayonBordurePetit),
                        boxShadow: DesignSystem.ombreDouce,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: Marges.moyenne, vertical: 6),
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: couleur.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icone, color: couleur, size: 22),
                        ),
                        title: Text(
                          _capitaliser(transaction.category),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: CodeCouleurs.textePrincipal),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (transaction.description != null &&
                                transaction.description!.isNotEmpty)
                              Text(
                                transaction.description!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: CodeCouleurs.texteSecondaire),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              DateFormat('dd MMM yyyy', 'fr')
                                  .format(transaction.date),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: CodeCouleurs.texteSecondaire),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Consumer<FournisseurDevise>(
                              builder: (context, fournisseurDevise, child) {
                                return Text(
                                  '${estRevenu ? '+' : '-'} ${FormateurMontant.formater(transaction.amount, fournisseurDevise.deviseActive)}',
                                  style: TextStyle(
                                    color: estRevenu
                                        ? CodeCouleurs.vert
                                        : CodeCouleurs.rouge,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: estRevenu
                                    ? CodeCouleurs.vert.withValues(alpha: 0.1)
                                    : CodeCouleurs.rouge.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                estRevenu ? 'Revenu' : 'Dépense',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: estRevenu
                                      ? CodeCouleurs.vert
                                      : CodeCouleurs.rouge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construireEtatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Marges.enorme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CodeCouleurs.primaire.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 50, color: CodeCouleurs.primaire),
            ),
            const SizedBox(height: Marges.grande),
            const Text(
              'Aucune transaction',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CodeCouleurs.textePrincipal),
            ),
            const SizedBox(height: Marges.petite),
            Text(
              'Appuyez sur + pour ajouter\nvotre première transaction.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: CodeCouleurs.texteSecondaire,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _capitaliser(String texte) {
    if (texte.isEmpty) return texte;
    return texte[0].toUpperCase() + texte.substring(1);
  }


}
