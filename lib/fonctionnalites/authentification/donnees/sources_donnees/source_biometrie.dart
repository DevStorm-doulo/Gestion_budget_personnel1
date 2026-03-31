import 'package:local_auth/local_auth.dart';
import '../../../../core/erreurs/exceptions.dart';

// ─────────────────────────────────────────────
// Source de données biométrique
// ─────────────────────────────────────────────
class SourceBiometrieImpl {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Vérifie si la biométrie est disponible sur l'appareil
  Future<bool> estDisponible() async {
    try {
      final peutAuthentifier = await _auth.canCheckBiometrics;
      final disponible = await _auth.isDeviceSupported();
      return peutAuthentifier && disponible;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie la disponibilité de la biométrie avant authentification
  Future<void> verifierDisponibiliteBiometrique() async {
    final peutAuthentifier = await _auth.canCheckBiometrics;
    final disponible = await _auth.isDeviceSupported();
    
    if (!peutAuthentifier || !disponible) {
      throw ExceptionBiometrie(
        'Biométrie non disponible sur cet appareil.',
      );
    }
    
    final typesBiometriques = await _auth.getAvailableBiometrics();
    if (typesBiometriques.isEmpty) {
      throw ExceptionBiometrie(
        'Aucune méthode biométrique configurée. Activez-la dans les paramètres.',
      );
    }
  }

  /// Lance l'authentification biométrique
  Future<bool> authentifier() async {
    try {
      await verifierDisponibiliteBiometrique();
      
      final resultat = await _auth.authenticate(
        localizedReason: 'Confirmez votre identité pour accéder à FlowCash',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return resultat;
    } on ExceptionBiometrie {
      rethrow;
    } catch (e) {
      return false;
    }
  }

  /// Retourne la liste des types de biométrie disponibles
  Future<List<BiometricType>> obtenirTypesDisponibles() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
