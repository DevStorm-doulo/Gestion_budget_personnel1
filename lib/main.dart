import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// --- Services
import 'core/services/service_preferences.dart';
import 'core/theme/fournisseur_theme.dart';

// --- Injection de dependances (Auth)
import 'fonctionnalites/authentification/donnees/sources_donnees/source_authentification_firebase.dart';
import 'fonctionnalites/authentification/donnees/depots/depot_authentification_impl.dart';
import 'fonctionnalites/authentification/domaine/cas_utilisation/obtenir_utilisateur_actuel.dart';
import 'fonctionnalites/authentification/domaine/cas_utilisation/s_inscrire.dart';
import 'fonctionnalites/authentification/domaine/cas_utilisation/se_connecter.dart';
import 'fonctionnalites/authentification/domaine/cas_utilisation/se_deconnecter.dart';
import 'fonctionnalites/authentification/presentation/fournisseurs/fournisseur_authentification.dart';
import 'fonctionnalites/authentification/presentation/pages/page_connexion.dart';

// --- Injection de dependances (Transactions)
import 'fonctionnalites/transactions/donnees/sources_donnees/source_transaction_firebase.dart';
import 'fonctionnalites/transactions/donnees/depots/depot_transaction_impl.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/ajouter_transaction.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/modifier_transaction.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/obtenir_transactions.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/supprimer_transaction.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/verifier_solde.dart';
import 'fonctionnalites/transactions/domaine/cas_utilisation/scanner_recu.dart';
import 'fonctionnalites/transactions/donnees/sources_donnees/source_reconnaissance_recu.dart';
import 'fonctionnalites/transactions/donnees/sources_donnees/source_image.dart';
import 'fonctionnalites/transactions/presentation/fournisseurs/fournisseur_transaction.dart';

// --- Injection de dependances (Dashboard)
import 'fonctionnalites/tableau_de_bord/domaine/cas_utilisation/obtenir_solde.dart';
import 'fonctionnalites/tableau_de_bord/domaine/cas_utilisation/obtenir_statistiques_mensuelles.dart';
import 'fonctionnalites/tableau_de_bord/presentation/fournisseurs/fournisseur_tableau_bord.dart';
import 'fonctionnalites/tableau_de_bord/presentation/pages/page_tableau_bord.dart';

// --- Injection de dependances (Budgets)
import 'fonctionnalites/budgets/donnees/sources_donnees/source_budget_firebase.dart';
import 'fonctionnalites/budgets/donnees/depots/depot_budget_impl.dart';
import 'fonctionnalites/budgets/domaine/cas_utilisation/obtenir_budgets.dart';
import 'fonctionnalites/budgets/domaine/cas_utilisation/ajouter_budget.dart';
import 'fonctionnalites/budgets/domaine/cas_utilisation/modifier_budget.dart';
import 'fonctionnalites/budgets/domaine/cas_utilisation/supprimer_budget.dart';
import 'fonctionnalites/budgets/presentation/fournisseurs/fournisseur_budget.dart';

// --- Injection de dependances (Devises)
import 'fonctionnalites/devises/donnees/sources_donnees/source_taux_change.dart';
import 'fonctionnalites/devises/donnees/depots/depot_devise_impl.dart';
import 'fonctionnalites/devises/domaine/cas_utilisation/obtenir_devises.dart';
import 'fonctionnalites/devises/domaine/cas_utilisation/convertir_montant.dart';
import 'fonctionnalites/devises/presentation/fournisseurs/fournisseur_devise.dart';

// --- Injection de dependances (Conversion)
import 'fonctionnalites/conversion/donnees/sources_donnees/source_taux_change.dart'
    as conversion_source;
import 'fonctionnalites/conversion/donnees/depots/depot_conversion_impl.dart'
    as conversion_depot;
import 'fonctionnalites/conversion/domaine/cas_utilisation/convertir_montant.dart'
    as conversion_cas;
import 'fonctionnalites/conversion/domaine/cas_utilisation/obtenir_taux_change.dart'
    as conversion_taux;
import 'fonctionnalites/conversion/domaine/cas_utilisation/obtenir_historique_conversions.dart'
    as conversion_historique;
import 'fonctionnalites/conversion/presentation/fournisseurs/fournisseur_conversion.dart';

// --- Injection de dependances (Analyse IA)
import 'fonctionnalites/analyse_ia/donnees/sources_donnees/source_analyse_gemini.dart';
import 'fonctionnalites/analyse_ia/donnees/depots/depot_analyse_ia_impl.dart';
import 'fonctionnalites/analyse_ia/domaine/cas_utilisation/analyser_depenses.dart';
import 'fonctionnalites/analyse_ia/presentation/fournisseurs/fournisseur_analyse_ia.dart';

// --- Services
import 'fonctionnalites/notifications/service_notification.dart';

import 'core/theme/theme_application.dart';
import 'fonctionnalites/onboarding/presentation/pages/page_onboarding.dart';
import 'fonctionnalites/authentification/presentation/pages/page_demarrage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erreur d\'initialisation de Firebase: $e');
  }

  // Initialisation des services
  final servicePreferences = ServicePreferences();
  await servicePreferences.initialiser();

  // Initialisation des dependances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final sourceAuth = SourceAuthentificationFirebaseImpl(firebaseAuth);
  final depotAuth = DepotAuthentificationImpl(sourceBdd: sourceAuth);

  final sourceTransaction = SourceTransactionFirebaseImpl(
      firestore: firestore, firebaseAuth: firebaseAuth);
  final depotTransaction = DepotTransactionImpl(sourceBdd: sourceTransaction);

  // Initialisation des dependances (Scan de reçus)
  final sourceReconnaissance = SourceReconnaissanceRecuImpl();
  final sourceImage = SourceImageImpl();
  final scannerRecu = ScannerRecu(
    sourceReconnaissance: sourceReconnaissance,
    sourceImage: sourceImage,
  );

  // Initialisation des dependances (Budgets)
  final sourceBudget = SourceBudgetFirebaseImpl(firestore: firestore);
  final depotBudget = DepotBudgetImpl(sourceBdd: sourceBudget);

  // Initialisation des dependances (Devises)
  final sourceTauxChange = SourceTauxChangeImpl(firestore: firestore);
  final depotDevise = DepotDeviseImpl(
    sourceTauxChange: sourceTauxChange,
    servicePreferences: servicePreferences,
  );

  // Création des fournisseurs
  final fournisseurTransaction = FournisseurTransaction(
    casAjouter: AjouterTransaction(depotTransaction),
    casObtenir: ObtenirTransactions(depotTransaction),
    casModifier: ModifierTransaction(depotTransaction),
    casSupprimer: SupprimerTransaction(depotTransaction),
    casVerifierSolde: VerifierSolde(depotTransaction),
    casScannerRecu: scannerRecu,
  );

  final fournisseurBudget = FournisseurBudget(
    casObtenirBudgets: ObtenirBudgets(depotBudget),
    casAjouterBudget: AjouterBudget(depotBudget),
    casModifierBudget: ModifierBudget(depotBudget),
    casSupprimerBudget: SupprimerBudget(depotBudget),
  );

  final fournisseurDevise = FournisseurDevise(
    casObtenirDevises: ObtenirDevises(depotDevise),
    casConvertirMontant: ConvertirMontant(depotDevise),
  );

  // Initialisation des dependances (Conversion)
  final sourceTauxChangeConversion = conversion_source.SourceTauxChangeImpl();
  final depotConversion = conversion_depot.DepotConversionImpl(
    sourceTauxChange: sourceTauxChangeConversion,
  );

  final fournisseurConversion = FournisseurConversion(
    convertirMontant: conversion_cas.ConvertirMontant(depotConversion),
    obtenirTauxChange: conversion_taux.ObtenirTauxChange(sourceTauxChangeConversion),
    obtenirHistoriqueConversions:
        conversion_historique.ObtenirHistoriqueConversions(depotConversion),
  );

  // Initialisation des dependances (Analyse IA)
  final httpClient = http.Client();
  final sourceGemini = SourceAnalyseGeminiImpl(client: httpClient);
  final depotAnalyseIA = DepotAnalyseIAImpl(
    sourceGemini: sourceGemini,
    firestore: firestore,
  );
  final fournisseurAnalyseIA = FournisseurAnalyseIA(
    casAnalyser: AnalyserDepenses(depotAnalyseIA),
  );

  // Initialiser le fournisseur de transactions (chargement SharedPreferences et transactions)
  await fournisseurTransaction.initialiser();
  await fournisseurTransaction.chargerTransactions();

  // Initialiser le fournisseur de thème
  final fournisseurTheme = FournisseurTheme();
  await fournisseurTheme.initialiser();

  // Initialiser le service de notification
  final serviceNotification = ServiceNotification();
  await serviceNotification.initialiser();
  await serviceNotification.demanderPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FournisseurAuthentification(
            casSeConnecter: SeConnecter(depotAuth),
            casSInscrire: SInscrire(depotAuth),
            casSeDeconnecter: SeDeconnecter(depotAuth),
            casObtenirUtilisateurActuel: ObtenirUtilisateurActuel(depotAuth),
          ),
        ),
        ChangeNotifierProvider.value(
          value: fournisseurTransaction,
        ),
        ChangeNotifierProvider(
          create: (_) => FournisseurTableauBord(
            casObtenirSolde: ObtenirSolde(depotTransaction),
            casObtenirStatistiques:
                ObtenirStatistiquesMensuelles(depotTransaction),
          ),
        ),
        ChangeNotifierProvider.value(
          value: fournisseurBudget,
        ),
        ChangeNotifierProvider.value(
          value: fournisseurTheme,
        ),
        ChangeNotifierProvider.value(
          value: fournisseurDevise,
        ),
        ChangeNotifierProvider.value(
          value: fournisseurConversion,
        ),
        ChangeNotifierProvider.value(
          value: fournisseurAnalyseIA,
        ),
      ],
      child: const MonApplicationBudget(),
    ),
  );
}

class MonApplicationBudget extends StatelessWidget {
  const MonApplicationBudget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FournisseurTheme>(
      builder: (context, fournisseurTheme, child) {
        return MaterialApp(
          title: 'Gestion Budget',
          debugShowCheckedModeBanner: false,
          theme: ThemeApplication.theme,
          darkTheme: ThemeApplication.themeSombre,
          themeMode: fournisseurTheme.modeActuel,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
          ],
          home: Consumer<FournisseurAuthentification>(
            builder: (context, auth, child) {
              if (auth.enChargement) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              // Vérifier si l'onboarding a été vu
              final servicePreferences = ServicePreferences();
              if (!servicePreferences.obtenirOnboardingVu()) {
                return const PageOnboarding();
              }

              if (auth.utilisateur != null) {
                // Vérifier si la biométrie est activée
                if (servicePreferences.obtenirBiometrieActivee()) {
                  return const PageDemarrage();
                }
                return const PageTableauBord();
              }
              return const PageConnexion();
            },
          ),
        );
      },
    );
  }
}
