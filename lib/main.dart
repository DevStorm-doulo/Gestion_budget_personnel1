import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'fonctionnalites/transactions/presentation/fournisseurs/fournisseur_transaction.dart';

// --- Injection de dependances (Dashboard)
import 'fonctionnalites/tableau_de_bord/domaine/cas_utilisation/obtenir_solde.dart';
import 'fonctionnalites/tableau_de_bord/domaine/cas_utilisation/obtenir_statistiques_mensuelles.dart';
import 'fonctionnalites/tableau_de_bord/presentation/fournisseurs/fournisseur_tableau_bord.dart';
import 'fonctionnalites/tableau_de_bord/presentation/pages/page_tableau_bord.dart';

import 'core/utilitaires/constantes.dart';
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

  // Initialisation des dependances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final sourceAuth = SourceAuthentificationFirebaseImpl(firebaseAuth);
  final depotAuth = DepotAuthentificationImpl(sourceBdd: sourceAuth);

  final sourceTransaction = SourceTransactionFirebaseImpl(
      firestore: firestore, firebaseAuth: firebaseAuth);
  final depotTransaction = DepotTransactionImpl(sourceBdd: sourceTransaction);

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
        ChangeNotifierProvider(
          create: (_) => FournisseurTransaction(
            casAjouter: AjouterTransaction(depotTransaction),
            casObtenir: ObtenirTransactions(depotTransaction),
            casModifier: ModifierTransaction(depotTransaction),
            casSupprimer: SupprimerTransaction(depotTransaction),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FournisseurTableauBord(
            casObtenirSolde: ObtenirSolde(depotTransaction),
            casObtenirStatistiques:
                ObtenirStatistiquesMensuelles(depotTransaction),
          ),
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
    return MaterialApp(
      title: 'Gestion Budget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: CodeCouleurs.fond,
        primaryColor: CodeCouleurs.primaire,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: CodeCouleurs.textePrincipal,
          displayColor: CodeCouleurs.textePrincipal,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: CodeCouleurs.primaire,
          primary: CodeCouleurs.primaire,
          secondary: CodeCouleurs.secondaire,
          surface: CodeCouleurs.surface,
          error: CodeCouleurs.rouge,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: CodeCouleurs.textePrincipal),
          titleTextStyle: TextStyle(
            color: CodeCouleurs.textePrincipal, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: CodeCouleurs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CodeCouleurs.primaire,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: CodeCouleurs.primaire.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.rayonBordureDefaut),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
            borderSide: const BorderSide(color: CodeCouleurs.primaire, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: Marges.moyenne, vertical: Marges.moyenne),
        ),
      ),
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
          if (auth.utilisateur != null) {
            return const PageTableauBord();
          }
          return const PageConnexion();
        },
      ),
    );
  }
}
