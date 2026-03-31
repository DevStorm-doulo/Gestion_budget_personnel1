import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/couleurs_application.dart';
import '../../../../core/theme/theme_application.dart';
import '../../domaine/entites/devise.dart';
import '../fournisseurs/fournisseur_conversion.dart';

// ─────────────────────────────────────────────
// Page de conversion de devises
// ─────────────────────────────────────────────
class PageConversion extends StatefulWidget {
  const PageConversion({super.key});

  @override
  State<PageConversion> createState() => _PageConversionState();
}

class _PageConversionState extends State<PageConversion> {
  final TextEditingController _montantController = TextEditingController();
  final FocusNode _montantFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fournisseur = Provider.of<FournisseurConversion>(context, listen: false);
      fournisseur.initialiser();
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    _montantFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApplication.fond,
      appBar: AppBar(
        title: const Text(
          'Conversion de devises',
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
      ),
      body: Consumer<FournisseurConversion>(
        builder: (context, fournisseur, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte de conversion
                _construireCarteConversion(fournisseur),
                
                const SizedBox(height: ThemeApplication.espaceGrand),
                
                // Résultat de la conversion
                if (fournisseur.derniereConversion != null)
                  _construireResultatConversion(fournisseur),
                
                const SizedBox(height: ThemeApplication.espaceGrand),
                
                // Historique des conversions
                _construireHistorique(fournisseur),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construireCarteConversion(FournisseurConversion fournisseur) {
    return Container(
      decoration: BoxDecoration(
        color: CouleursApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
        boxShadow: ThemeApplication.ombreDouce,
      ),
      padding: const EdgeInsets.all(ThemeApplication.espaceGrand),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ montant
          TextField(
            controller: _montantController,
            focusNode: _montantFocusNode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant',
              hintText: 'Entrez le montant à convertir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _montantController.clear();
                  fournisseur.effacerErreur();
                },
              ),
            ),
            onChanged: (valeur) {
              if (valeur.isNotEmpty) {
                final montant = double.tryParse(valeur);
                if (montant != null && montant > 0) {
                  fournisseur.convertir(montant);
                }
              }
            },
          ),
          
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          
          // Sélecteurs de devises
          Row(
            children: [
              Expanded(
                child: _construireSelecteurDevise(
                  titre: 'De',
                  devise: fournisseur.deviseSource,
                  onTap: () => _afficherSelecteurDevise(context, true),
                ),
              ),
              const SizedBox(width: ThemeApplication.espacePetite),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded),
                onPressed: () {
                  fournisseur.inverserDevises();
                  _montantController.clear();
                },
                color: CouleursApplication.primaire,
              ),
              const SizedBox(width: ThemeApplication.espacePetite),
              Expanded(
                child: _construireSelecteurDevise(
                  titre: 'À',
                  devise: fournisseur.deviseCible,
                  onTap: () => _afficherSelecteurDevise(context, false),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          
          // Taux de change
          if (fournisseur.tauxActuel > 0)
            Center(
              child: Text(
                'Taux: 1 ${fournisseur.deviseSource.code} = ${fournisseur.tauxActuel.toStringAsFixed(4)} ${fournisseur.deviseCible.code}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
            ),
          
          // Message d'erreur
          if (fournisseur.messageErreur != null)
            Container(
              margin: const EdgeInsets.only(top: ThemeApplication.espacePetite),
              padding: const EdgeInsets.all(ThemeApplication.espacePetite),
              decoration: BoxDecoration(
                color: CouleursApplication.erreur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeApplication.rayonPetit),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: CouleursApplication.erreur, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fournisseur.messageErreur!,
                      style: const TextStyle(
                          color: CouleursApplication.erreur, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _construireSelecteurDevise({
    required String titre,
    required Devise devise,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
        decoration: BoxDecoration(
          color: CouleursApplication.fond,
          borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
          border: Border.all(
            color: CouleursApplication.texteClair.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(
                fontSize: 12,
                color: CouleursApplication.texteSecondaire,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  devise.drapeau,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  devise.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: CouleursApplication.textePrincipal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireResultatConversion(FournisseurConversion fournisseur) {
    final conversion = fournisseur.derniereConversion!;
    final formatMontant = NumberFormat.currency(
      symbol: conversion.deviseCible.symbole,
      decimalDigits: 2,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: CouleursApplication.degradePremium,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
        boxShadow: ThemeApplication.ombreColoree,
      ),
      padding: const EdgeInsets.all(ThemeApplication.espaceGrand),
      child: Column(
        children: [
          const Text(
            'Résultat',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          Text(
            formatMontant.format(conversion.montantCible),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          Text(
            '${conversion.deviseSource.drapeau} ${conversion.montantSource.toStringAsFixed(2)} ${conversion.deviseSource.symbole}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireHistorique(FournisseurConversion fournisseur) {
    if (fournisseur.historique.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique des conversions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CouleursApplication.textePrincipal,
          ),
        ),
        const SizedBox(height: ThemeApplication.espaceMoyenne),
        Container(
          decoration: BoxDecoration(
            color: CouleursApplication.surface,
            borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
            boxShadow: ThemeApplication.ombreDouce,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fournisseur.historique.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversion = fournisseur.historique[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CouleursApplication.primaire.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.currency_exchange_rounded,
                    color: CouleursApplication.primaire,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${conversion.deviseSource.drapeau} ${conversion.montantSource.toStringAsFixed(2)} → ${conversion.deviseCible.drapeau} ${conversion.montantCible.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(conversion.dateConversion),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CouleursApplication.texteSecondaire,
                  ),
                ),
                trailing: Text(
                  'Taux: ${conversion.tauxChange.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CouleursApplication.texteSecondaire,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _afficherSelecteurDevise(BuildContext context, bool estSource) {
    final fournisseur = Provider.of<FournisseurConversion>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: CouleursApplication.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeApplication.espaceGrand),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estSource ? 'Choisir la devise source' : 'Choisir la devise cible',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApplication.textePrincipal,
              ),
            ),
            const SizedBox(height: ThemeApplication.espaceMoyenne),
            ...Devise.devises.map((devise) {
              final estSelectionnee = estSource
                  ? fournisseur.deviseSource.code == devise.code
                  : fournisseur.deviseCible.code == devise.code;
              
              return ListTile(
                leading: Text(
                  devise.drapeau,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  '${devise.nom} (${devise.code})',
                  style: TextStyle(
                    fontWeight: estSelectionnee ? FontWeight.bold : FontWeight.normal,
                    color: estSelectionnee
                        ? CouleursApplication.primaire
                        : CouleursApplication.textePrincipal,
                  ),
                ),
                trailing: estSelectionnee
                    ? const Icon(Icons.check_rounded, color: CouleursApplication.primaire)
                    : null,
                onTap: () {
                  if (estSource) {
                    fournisseur.changerDeviseSource(devise);
                  } else {
                    fournisseur.changerDeviseCible(devise);
                  }
                  Navigator.pop(context);
                  _montantController.clear();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
