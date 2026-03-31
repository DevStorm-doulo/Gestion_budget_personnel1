import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../domaine/entites/devise.dart';

// ─────────────────────────────────────────────
// Source de données taux de change
// ─────────────────────────────────────────────
class SourceTauxChangeImpl {
  final FirebaseFirestore firestore;
  final String _urlApi = 'https://api.exchangerate-api.com/v4/latest/XOF';
  
  // Taux de fallback en cas d'erreur réseau
  static const Map<String, double> _tauxFallback = {
    'EUR': 655.957,
    'USD': 600.0,
    'GBP': 760.0,
    'MAD': 60.0,
  };

  SourceTauxChangeImpl({required this.firestore});

  /// Obtient les taux de change depuis l'API ou le cache Firestore
  Future<Map<String, double>> obtenirTaux() async {
    try {
      // Vérifier le cache Firestore
      final cacheValide = await _verifierCache();
      if (cacheValide) {
        return await _obtenirTauxDepuisCache();
      }

      // Appeler l'API
      final taux = await _appelerApi();
      
      // Mettre à jour le cache
      await _mettreAJourCache(taux);
      
      return taux;
    } catch (e) {
      // Fallback sur taux statiques
      return _tauxFallback;
    }
  }

  /// Vérifie si le cache Firestore est encore valide (24h)
  Future<bool> _verifierCache() async {
    try {
      final doc = await firestore
          .collection('parametres')
          .doc('taux_change')
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final dateMiseAJour = (data['dateMiseAJour'] as Timestamp).toDate();
      final maintenant = DateTime.now();
      final difference = maintenant.difference(dateMiseAJour);

      return difference.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  /// Obtient les taux depuis le cache Firestore
  Future<Map<String, double>> _obtenirTauxDepuisCache() async {
    final doc = await firestore
        .collection('parametres')
        .doc('taux_change')
        .get();

    final data = doc.data()!;
    final taux = Map<String, double>.from(data['taux'] as Map);
    return taux;
  }

  /// Appelle l'API pour obtenir les taux de change
  Future<Map<String, double>> _appelerApi() async {
    final response = await http.get(Uri.parse(_urlApi));
    
    if (response.statusCode != 200) {
      throw Exception('Erreur API: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final rates = data['rates'] as Map<String, dynamic>;
    
    // Extraire uniquement les devises supportées
    final taux = <String, double>{};
    for (final devise in Devise.devisesSupportees) {
      if (devise.code != 'XOF' && rates.containsKey(devise.code)) {
        taux[devise.code] = (rates[devise.code] as num).toDouble();
      }
    }

    return taux;
  }

  /// Met à jour le cache Firestore avec les nouveaux taux
  Future<void> _mettreAJourCache(Map<String, double> taux) async {
    await firestore
        .collection('parametres')
        .doc('taux_change')
        .set({
      'taux': taux,
      'dateMiseAJour': Timestamp.fromDate(DateTime.now()),
    });
  }
}
