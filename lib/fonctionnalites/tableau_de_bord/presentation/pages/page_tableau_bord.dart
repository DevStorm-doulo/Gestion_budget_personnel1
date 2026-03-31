import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../fournisseurs/fournisseur_tableau_bord.dart';
import '../../../authentification/presentation/fournisseurs/fournisseur_authentification.dart';
import '../../../transactions/presentation/pages/page_liste_transactions.dart';
import '../../../transactions/presentation/pages/page_ajout_transaction.dart';
import '../../../transactions/presentation/fournisseurs/fournisseur_transaction.dart';
import '../../../../core/theme/couleurs_application.dart';
import '../../../../core/theme/theme_application.dart';
import '../../../../core/widgets/carte_degradee.dart';
import '../../../../core/widgets/effet_shimmer.dart';
import '../../../export/service_export_pdf.dart';
import '../../../parametres/presentation/pages/page_parametres.dart';
import '../../../devises/presentation/fournisseurs/fournisseur_devise.dart';
import '../../../../core/utilitaires/formateur_montant.dart';
import '../../../analyse_ia/presentation/fournisseurs/fournisseur_analyse_ia.dart';
import '../../../analyse_ia/presentation/widgets/carte_conseils_ia.dart';

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
      Provider.of<FournisseurTableauBord>(context, listen: false)
          .chargerDonnees();
      final auth =
          Provider.of<FournisseurAuthentification>(context, listen: false);
      if (auth.utilisateur != null) {
        Provider.of<FournisseurAnalyseIA>(context, listen: false)
            .analyser(auth.utilisateur!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<FournisseurAuthentification>(context, listen: false);

    final pages = [
      _construireVueTableauBord(),
      const PageListeTransactions(),
    ];

    return Scaffold(
      backgroundColor: CouleursApplication.fond,
      appBar: AppBar(
        title: Text(
          _indexMenu == 0 ? 'Mon Budget' : 'Transactions',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: CouleursApplication.textePrincipal,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Bouton paramètres
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: CouleursApplication.fond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded,
                  color: CouleursApplication.primaire),
              tooltip: 'Paramètres',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PageParametres()),
              ),
            ),
          ),
          // Bouton export PDF
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: CouleursApplication.fond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded,
                  color: CouleursApplication.primaire),
              tooltip: 'Exporter PDF',
              onPressed: () => _exporterPdf(),
            ),
          ),
          // Bouton déconnexion
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: CouleursApplication.fond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: CouleursApplication.texteSecondaire),
              tooltip: 'Déconnexion',
              onPressed: () async {
                final confirmation = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeApplication.rayonGrand),
                    ),
                    title: const Text('Déconnexion',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    content:
                        const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApplication.primaire,
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
        duration: ThemeApplication.animationMoyenne,
        child: pages[_indexMenu],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          gradient: CouleursApplication.degradeSecondaire,
          borderRadius: BorderRadius.circular(ThemeApplication.rayonMoyen),
          boxShadow: [
            BoxShadow(
              color: CouleursApplication.secondaire.withValues(alpha: 0.4),
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            final tableauBord =
                Provider.of<FournisseurTableauBord>(context, listen: false);
            final transactionsFournisseur =
                Provider.of<FournisseurTransaction>(context, listen: false);
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
          color: CouleursApplication.surface,
          boxShadow: ThemeApplication.ombreMoyenne,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ThemeApplication.rayonGrand)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ThemeApplication.rayonGrand)),
          child: BottomNavigationBar(
            currentIndex: _indexMenu,
            onTap: (index) => setState(() => _indexMenu = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: CouleursApplication.primaire,
            unselectedItemColor: CouleursApplication.texteSecondaire,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Transactions'),
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
          return const ShimmerDashboard();
        }

        // Afficher le message d'erreur s'il y a lieu
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
                    style: const TextStyle(
                        color: CouleursApplication.erreur, fontSize: 16),
                  ),
                  const SizedBox(height: ThemeApplication.espaceMoyenne),
                  ElevatedButton(
                    onPressed: () => fournisseur.chargerDonnees(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
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
                    color: CouleursApplication.primaire.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      size: 44, color: CouleursApplication.primaire),
                ),
                const SizedBox(height: ThemeApplication.espaceMoyenne),
                const Text('Aucune donnée pour ce mois',
                    style: TextStyle(
                        color: CouleursApplication.texteSecondaire,
                        fontSize: 16)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              ThemeApplication.espaceMoyenne,
              ThemeApplication.espacePetite,
              ThemeApplication.espaceMoyenne,
              ThemeApplication.espaceMoyenne),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Carte Solde Premium ──
              _carteSoldePremium(fournisseur),
              const SizedBox(height: ThemeApplication.espaceMoyenne),

              // ── Revenus / Dépenses ──
              Row(
                children: [
                  Expanded(
                      child: _carteStatistiquePremium(
                    label: 'Revenus',
                    montant: stats.totalRevenus,
                    icone: Icons.south_rounded,
                    couleur: CouleursApplication.succes,
                    prefixe: '+',
                    degrade: CouleursApplication.degradeSucces,
                  )),
                  const SizedBox(width: ThemeApplication.espaceMoyenne),
                  Expanded(
                      child: _carteStatistiquePremium(
                    label: 'Dépenses',
                    montant: stats.totalDepenses,
                    icone: Icons.north_rounded,
                    couleur: CouleursApplication.erreur,
                    prefixe: '-',
                    degrade: CouleursApplication.degradeErreur,
                  )),
                ],
              ),

              // ── Graphique évolution mensuelle ──
              const SizedBox(height: ThemeApplication.espaceGrand),
              _enteteSection('Évolution mensuelle'),
              const SizedBox(height: ThemeApplication.espaceMoyenne),
              _carteGraphiqueEvolution(stats),

              // ── Graphique répartition ──
              if (stats.depensesParCategorie.isNotEmpty) ...[
                const SizedBox(height: ThemeApplication.espaceGrand),
                _enteteSection('Répartition des dépenses'),
                const SizedBox(height: ThemeApplication.espaceMoyenne),
                _carteGraphique(stats.depensesParCategorie),
              ],

              // ── Conseils IA ──
              const SizedBox(height: ThemeApplication.espaceGrand),
              _enteteSection('Assistant financier'),
              const SizedBox(height: ThemeApplication.espaceMoyenne),
              const CarteConseilsIA(),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ── Carte du solde premium ──────────────────────────
  Widget _carteSoldePremium(FournisseurTableauBord fournisseur) {
    final mois = DateFormat('MMMM yyyy', 'fr').format(DateTime.now());

    return CarteDegradee.principale(
      remplissage: const EdgeInsets.symmetric(
        vertical: ThemeApplication.espaceTresGrand,
        horizontal: ThemeApplication.espaceGrand,
      ),
      enfant: Column(
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
                  duration: ThemeApplication.animationRapide,
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
            duration: ThemeApplication.animationMoyenne,
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
                ? MontantStylise(
                    key: const ValueKey('visible'),
                    montant: fournisseur.soldeActuel,
                    couleur: Colors.white,
                    taillePolice: 36,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  // ── Carte statistique premium (revenus / dépenses) ──
  Widget _carteStatistiquePremium({
    required String label,
    required double montant,
    required IconData icone,
    required Color couleur,
    required String prefixe,
    required LinearGradient degrade,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CouleursApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
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
              const SizedBox(width: ThemeApplication.espacePetite),
              Text(label,
                  style: const TextStyle(
                      color: CouleursApplication.texteSecondaire,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: ThemeApplication.espacePetite),
          Text(
            '$prefixe ${_formaterMontant(montant)} F',
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
          color: CouleursApplication.textePrincipal),
    );
  }

  // ── Carte graphique évolution ─────────────────────────
  Widget _carteGraphiqueEvolution(dynamic stats) {
    // Données simulées pour l'évolution mensuelle
    final List<FlSpot> spots = [
      const FlSpot(0, 3),
      const FlSpot(1, 2),
      const FlSpot(2, 4),
      const FlSpot(3, 3.5),
      const FlSpot(4, 5),
      const FlSpot(5, 4.5),
    ];

    return Container(
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
      decoration: BoxDecoration(
        color: CouleursApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
        boxShadow: ThemeApplication.ombreDouce,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          CouleursApplication.texteClair.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const mois = [
                          'Jan',
                          'Fév',
                          'Mar',
                          'Avr',
                          'Mai',
                          'Juin'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < mois.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              mois[value.toInt()],
                              style: const TextStyle(
                                color: CouleursApplication.texteSecondaire,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}k',
                          style: const TextStyle(
                            color: CouleursApplication.texteSecondaire,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: CouleursApplication.degradePrimaire,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          CouleursApplication.primaire.withValues(alpha: 0.3),
                          CouleursApplication.primaire.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte graphique camembert ─────────────────────────
  Widget _carteGraphique(Map<String, double> depenses) {
    final entrees = depenses.entries.toList();
    return Container(
      padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
      decoration: BoxDecoration(
        color: CouleursApplication.surface,
        borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
        boxShadow: ThemeApplication.ombreDouce,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: entrees.map((e) {
                  final couleur =
                      CouleursApplication.couleurParCategorie(e.key);
                  return PieChartSectionData(
                    color: couleur,
                    value: e.value,
                    title: '',
                    radius: 55,
                  );
                }).toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                centerSpaceColor: CouleursApplication.surface,
              ),
            ),
          ),
          const SizedBox(height: ThemeApplication.espaceMoyenne),
          // Légende
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entrees.map((e) {
              final couleur = CouleursApplication.couleurParCategorie(e.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: couleur, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.key[0].toUpperCase()}${e.key.substring(1)} · ${_formaterMontant(e.value)} F',
                    style: const TextStyle(
                        fontSize: 12,
                        color: CouleursApplication.texteSecondaire),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _exporterPdf() async {
    final fournisseur =
        Provider.of<FournisseurTableauBord>(context, listen: false);
    final stats = fournisseur.statistiques;

    if (stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune donnée à exporter'),
          backgroundColor: CouleursApplication.erreur,
        ),
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: CouleursApplication.primaire,
        ),
      ),
    );

    try {
      final servicePdf = ServiceExportPdf();
      final transactionsFournisseur =
          Provider.of<FournisseurTransaction>(context, listen: false);
      final transactions = transactionsFournisseur.transactions;

      final pdfBytes = await servicePdf.genererRapportMensuel(
        mois: DateTime.now().month,
        annee: DateTime.now().year,
        solde: fournisseur.soldeActuel,
        totalRevenus: stats.totalRevenus,
        totalDepenses: stats.totalDepenses,
        depensesParCategorie: stats.depensesParCategorie,
        transactions: transactions,
      );

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Partager le PDF
      final nomFichier =
          'rapport_budget_${DateFormat('yyyy_MM').format(DateTime.now())}';
      await servicePdf.partagerPdf(pdfBytes, nomFichier);
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export: $e'),
          backgroundColor: CouleursApplication.erreur,
        ),
      );
    }
  }

  String _formaterMontant(double montant) {
    final fournisseurDevise =
        Provider.of<FournisseurDevise>(context, listen: false);
    return FormateurMontant.formater(
      montant,
      fournisseurDevise.deviseActive,
    );
  }
}
