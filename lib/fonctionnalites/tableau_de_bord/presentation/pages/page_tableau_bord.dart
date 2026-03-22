import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../fournisseurs/fournisseur_tableau_bord.dart';
import '../../../authentification/presentation/fournisseurs/fournisseur_authentification.dart';
import '../../../transactions/presentation/pages/page_liste_transactions.dart';
import '../../../transactions/presentation/pages/page_ajout_transaction.dart';
import '../../../transactions/presentation/fournisseurs/fournisseur_transaction.dart';
import '../../../../core/utilitaires/constantes.dart';

class PageTableauBord extends StatefulWidget {
  const PageTableauBord({super.key});

  @override
  State<PageTableauBord> createState() => _PageTableauBordState();
}

class _PageTableauBordState extends State<PageTableauBord> {
  int _indexMenu = 0;
  bool _soldeVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FournisseurTableauBord>(context, listen: false).chargerDonnees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FournisseurAuthentification>(context, listen: false);

    final pages = [
      _construireVueTableauBord(),
      const PageListeTransactions(),
    ];

    return Scaffold(
      backgroundColor: CodeCouleurs.fond,
      appBar: AppBar(
        title: Text(
          _indexMenu == 0 ? 'Mon Budget' : 'Transactions',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: CodeCouleurs.textePrincipal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: CodeCouleurs.fond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: CodeCouleurs.texteSecondaire),
              tooltip: 'Déconnexion',
              onPressed: () async {
                final confirmation = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
                    ),
                    title: const Text('Déconnexion',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CodeCouleurs.primaire,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );
                if (confirmation == true) {
                  await auth.seDeconnecter();
                }
              },
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_indexMenu],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          gradient: CodeCouleurs.degradeSecondaire,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CodeCouleurs.secondaire.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Ajouter',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            final tableauBord = Provider.of<FournisseurTableauBord>(context, listen: false);
            final transactionsFournisseur = Provider.of<FournisseurTransaction>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PageAjoutTransaction()),
            ).then((_) {
              if (mounted) {
                tableauBord.chargerDonnees();
                transactionsFournisseur.chargerTransactions();
              }
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CodeCouleurs.surface,
          boxShadow: DesignSystem.ombreMoyenne,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignSystem.rayonBordureDefaut)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignSystem.rayonBordureDefaut)),
          child: BottomNavigationBar(
            currentIndex: _indexMenu,
            onTap: (index) => setState(() => _indexMenu = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: CodeCouleurs.primaire,
            unselectedItemColor: CodeCouleurs.texteSecondaire,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded), label: 'Transactions'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireVueTableauBord() {
    return Consumer<FournisseurTableauBord>(
      builder: (context, fournisseur, child) {
        if (fournisseur.enChargement) {
          return const Center(
              child: CircularProgressIndicator(color: CodeCouleurs.primaire));
        }

        final stats = fournisseur.statistiques;
        if (stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: CodeCouleurs.primaire.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      size: 44, color: CodeCouleurs.primaire),
                ),
                const SizedBox(height: Marges.moyenne),
                const Text('Aucune donnée pour ce mois',
                    style: TextStyle(
                        color: CodeCouleurs.texteSecondaire, fontSize: 16)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              Marges.moyenne, Marges.petite, Marges.moyenne, Marges.moyenne),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Carte Solde ──
              _carteSolde(fournisseur),
              const SizedBox(height: Marges.moyenne),

              // ── Revenus / Dépenses ──
              Row(
                children: [
                  Expanded(child: _carteStatistique(
                    label: 'Revenus',
                    montant: stats.totalRevenus,
                    icone: Icons.south_rounded,
                    couleur: CodeCouleurs.vert,
                    prefixe: '+',
                  )),
                  const SizedBox(width: Marges.moyenne),
                  Expanded(child: _carteStatistique(
                    label: 'Dépenses',
                    montant: stats.totalDepenses,
                    icone: Icons.north_rounded,
                    couleur: CodeCouleurs.rouge,
                    prefixe: '-',
                  )),
                ],
              ),

              // ── Graphique répartition ──
              if (stats.depensesParCategorie.isNotEmpty) ...[
                const SizedBox(height: Marges.enorme),
                _enteteSection('Répartition des dépenses'),
                const SizedBox(height: Marges.moyenne),
                _carteGraphique(stats.depensesParCategorie),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ── Carte du solde ──────────────────────────
  Widget _carteSolde(FournisseurTableauBord fournisseur) {
    final mois = DateFormat('MMMM yyyy', 'fr').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        gradient: DesignSystem.degradePrimaire,
        borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
        boxShadow: DesignSystem.ombreColoree,
      ),
      padding: const EdgeInsets.symmetric(
          vertical: Marges.enorme, horizontal: Marges.grande),
      child: Column(
        children: [
          // Label + toggle visibilité
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Solde Actuel',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _soldeVisible = !_soldeVisible),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _soldeVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    key: ValueKey(_soldeVisible),
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Montant animé
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(anim),
                child: child,
              ),
            ),
            child: _soldeVisible
                ? Text(
                    key: const ValueKey('visible'),
                    '${formatFCFA(fournisseur.soldeActuel)} FCFA',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                  )
                : const Text(
                    key: ValueKey('masque'),
                    '••••••• FCFA',
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4),
                  ),
          ),
          const SizedBox(height: 6),
          // Mois en cours
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              mois.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte statistique (revenus / dépenses) ──
  Widget _carteStatistique({
    required String label,
    required double montant,
    required IconData icone,
    required Color couleur,
    required String prefixe,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CodeCouleurs.surface,
        borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
        boxShadow: DesignSystem.ombreDouce,
      ),
      padding: const EdgeInsets.all(Marges.moyenne),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: couleur, size: 16),
              ),
              const SizedBox(width: Marges.petite),
              Text(label,
                  style: const TextStyle(
                      color: CodeCouleurs.texteSecondaire, fontSize: 12)),
            ],
          ),
          const SizedBox(height: Marges.petite),
          Text(
            '$prefixe ${formatFCFA(montant)} F',
            style: TextStyle(
                color: couleur, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ── En-tête de section ──────────────────────
  Widget _enteteSection(String titre) {
    return Text(
      titre,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: CodeCouleurs.textePrincipal),
    );
  }

  // ── Carte graphique ─────────────────────────
  Widget _carteGraphique(Map<String, double> depenses) {
    final entrees = depenses.entries.toList();
    return Container(
      padding: const EdgeInsets.all(Marges.moyenne),
      decoration: BoxDecoration(
        color: CodeCouleurs.surface,
        borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
        boxShadow: DesignSystem.ombreDouce,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: entrees.map((e) {
                  final couleur = couleurCategorie(e.key);
                  return PieChartSectionData(
                    color: couleur,
                    value: e.value,
                    title: '',
                    radius: 55,
                  );
                }).toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                centerSpaceColor: CodeCouleurs.surface,
              ),
            ),
          ),
          const SizedBox(height: Marges.moyenne),
          // Légende
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entrees.map((e) {
              final couleur = couleurCategorie(e.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: couleur, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.key[0].toUpperCase()}${e.key.substring(1)} · ${formatFCFA(e.value)} F',
                    style: const TextStyle(
                        fontSize: 12, color: CodeCouleurs.texteSecondaire),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
