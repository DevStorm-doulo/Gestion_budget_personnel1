import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/couleurs_application.dart';
import '../../../../core/theme/theme_application.dart';
import '../../../../core/theme/fournisseur_theme.dart';
import '../../../authentification/presentation/fournisseurs/fournisseur_authentification.dart';
import '../../../../core/services/service_preferences.dart';
import '../../../devises/presentation/fournisseurs/fournisseur_devise.dart';
import '../../../devises/domaine/entites/devise.dart';

// ─────────────────────────────────────────────
// Page des paramètres
// ─────────────────────────────────────────────
class PageParametres extends StatelessWidget {
  const PageParametres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApplication.fond,
      appBar: AppBar(
        title: const Text(
          'Paramètres',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeApplication.espaceMoyenne),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Apparence
            _construireSection(
              titre: 'Apparence',
              enfants: [
                _construireOptionTheme(context),
              ],
            ),
            
            const SizedBox(height: ThemeApplication.espaceGrand),
            
            // Section Sécurité
            _construireSection(
              titre: 'Sécurité',
              enfants: [
                _construireOptionBiometrie(context),
              ],
            ),
            
            const SizedBox(height: ThemeApplication.espaceGrand),
            
            // Section Devise
            _construireSection(
              titre: 'Devise d\'affichage',
              enfants: [
                _construireOptionDevise(context),
              ],
            ),
            
            const SizedBox(height: ThemeApplication.espaceGrand),
            
            // Section À propos
            _construireSection(
              titre: 'À propos',
              enfants: [
                _construireElement(
                  icone: Icons.info_outline_rounded,
                  titre: 'Version',
                  sousTitre: '1.0.0',
                ),
                _construireElement(
                  icone: Icons.description_outlined,
                  titre: 'Licence',
                  sousTitre: 'MIT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireSection({
    required String titre,
    required List<Widget> enfants,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CouleursApplication.texteSecondaire,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: ThemeApplication.espacePetite),
        Container(
          decoration: BoxDecoration(
            color: CouleursApplication.surface,
            borderRadius: BorderRadius.circular(ThemeApplication.rayonGrand),
            boxShadow: ThemeApplication.ombreDouce,
          ),
          child: Column(
            children: enfants,
          ),
        ),
      ],
    );
  }

  Widget _construireOptionTheme(BuildContext context) {
    return Consumer<FournisseurTheme>(
      builder: (context, fournisseurTheme, child) {
        return Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CouleursApplication.primaire.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: CouleursApplication.primaire,
                  size: 20,
                ),
              ),
              title: const Text(
                'Thème',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: CouleursApplication.textePrincipal,
                ),
              ),
              subtitle: Text(
                _obtenirNomTheme(fournisseurTheme.modeActuel),
                style: const TextStyle(
                  fontSize: 14,
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: CouleursApplication.texteClair,
              ),
              onTap: () => _afficherDialogueTheme(context, fournisseurTheme),
            ),
          ],
        );
      },
    );
  }

  Widget _construireOptionBiometrie(BuildContext context) {
    return Consumer<FournisseurAuthentification>(
      builder: (context, fournisseurAuth, child) {
        if (!fournisseurAuth.biometrieDisponible) {
          return const SizedBox.shrink();
        }
        
        return SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CouleursApplication.primaire.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: CouleursApplication.primaire,
              size: 20,
            ),
          ),
          title: const Text(
            'Authentification biométrique',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: CouleursApplication.textePrincipal,
            ),
          ),
          subtitle: Text(
            'Utiliser ${_obtenirTypeBiometrie(fournisseurAuth)} pour se connecter',
            style: const TextStyle(
              fontSize: 14,
              color: CouleursApplication.texteSecondaire,
            ),
          ),
          value: fournisseurAuth.biometrieActivee,
          onChanged: (valeur) async {
            final servicePreferences = ServicePreferences();
            await servicePreferences.sauvegarderBiometrieActivee(valeur);
            fournisseurAuth.biometrieActivee = valeur;
          },
          activeColor: CouleursApplication.primaire,
        );
      },
    );
  }

  String _obtenirTypeBiometrie(FournisseurAuthentification fournisseurAuth) {
    if (fournisseurAuth.typesBiometrie.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (fournisseurAuth.typesBiometrie.contains(BiometricType.fingerprint)) {
      return 'l\'empreinte digitale';
    }
    return 'la biométrie';
  }

  Widget _construireOptionDevise(BuildContext context) {
    return Consumer<FournisseurDevise>(
      builder: (context, fournisseurDevise, child) {
        return Column(
          children: Devise.devisesSupportees.map((devise) {
            final estSelectionnee = fournisseurDevise.deviseActive.code == devise.code;
            return RadioListTile<Devise>(
              title: Text(
                '${_obtenirEmojiDrapeau(devise.code)} ${devise.nom}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: CouleursApplication.textePrincipal,
                ),
              ),
              subtitle: Text(
                devise.symbole,
                style: const TextStyle(
                  fontSize: 14,
                  color: CouleursApplication.texteSecondaire,
                ),
              ),
              value: devise,
              groupValue: fournisseurDevise.deviseActive,
              onChanged: (valeur) {
                if (valeur != null) {
                  fournisseurDevise.changerDevise(valeur);
                }
              },
              activeColor: CouleursApplication.primaire,
            );
          }).toList(),
        );
      },
    );
  }

  String _obtenirEmojiDrapeau(String codeDevise) {
    switch (codeDevise) {
      case 'XOF':
        return '🌍';
      case 'EUR':
        return '🇪🇺';
      case 'USD':
        return '🇺🇸';
      case 'GBP':
        return '🇬🇧';
      case 'MAD':
        return '🇲🇦';
      default:
        return '💱';
    }
  }

  Widget _construireElement({
    required IconData icone,
    required String titre,
    required String sousTitre,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CouleursApplication.primaire.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icone,
          color: CouleursApplication.primaire,
          size: 20,
        ),
      ),
      title: Text(
        titre,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: CouleursApplication.textePrincipal,
        ),
      ),
      subtitle: Text(
        sousTitre,
        style: const TextStyle(
          fontSize: 14,
          color: CouleursApplication.texteSecondaire,
        ),
      ),
    );
  }

  String _obtenirNomTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Automatique (système)';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
    }
  }

  void _afficherDialogueTheme(BuildContext context, FournisseurTheme fournisseurTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _construireOptionRadio(
              context: context,
              titre: 'Clair',
              valeur: ThemeMode.light,
              groupeValeur: fournisseurTheme.modeActuel,
              onChanged: (valeur) {
                fournisseurTheme.changerTheme(valeur!);
                Navigator.pop(context);
              },
            ),
            _construireOptionRadio(
              context: context,
              titre: 'Sombre',
              valeur: ThemeMode.dark,
              groupeValeur: fournisseurTheme.modeActuel,
              onChanged: (valeur) {
                fournisseurTheme.changerTheme(valeur!);
                Navigator.pop(context);
              },
            ),
            _construireOptionRadio(
              context: context,
              titre: 'Automatique (système)',
              valeur: ThemeMode.system,
              groupeValeur: fournisseurTheme.modeActuel,
              onChanged: (valeur) {
                fournisseurTheme.changerTheme(valeur!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireOptionRadio({
    required BuildContext context,
    required String titre,
    required ThemeMode valeur,
    required ThemeMode groupeValeur,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(titre),
      value: valeur,
      groupValue: groupeValeur,
      onChanged: onChanged,
      activeColor: CouleursApplication.primaire,
    );
  }
}
