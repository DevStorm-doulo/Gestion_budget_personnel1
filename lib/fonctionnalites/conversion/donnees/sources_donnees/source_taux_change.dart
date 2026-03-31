import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Source de données pour les taux de change
// ─────────────────────────────────────────────
abstract class SourceTauxChange {
  Future<Map<String, double>> obtenirTaux(String deviseSource);
  Future<double> obtenirTauxConversion(String deviseSource, String deviseCible);
}

class SourceTauxChangeImpl implements SourceTauxChange {
  final String _baseUrl = 'https://open.er-api.com/v6/latest';
  final String _cleCache = 'taux_change_cache';
  final String _cleCacheDate = 'taux_change_cache_date';
  final Duration _dureeCache = const Duration(hours: 1);

  @override
  Future<Map<String, double>> obtenirTaux(String deviseSource) async {
    try {
      // Vérifier le cache
      final cacheValide = await _verifierCache();
      if (cacheValide) {
        final taux = await _obtenirDepuisCache(deviseSource);
        if (taux != null) return taux;
      }

      // Récupérer depuis l'API
      final response = await http.get(
        Uri.parse('$_baseUrl/$deviseSource'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        final taux = <String, double>{};
        for (final entry in rates.entries) {
          taux[entry.key] = (entry.value as num).toDouble();
        }

        // Sauvegarder dans le cache
        await _sauvegarderDansCache(deviseSource, taux);
        
        return taux;
      } else {
        throw Exception('Erreur lors de la récupération des taux: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final taux = await _obtenirDepuisCache(deviseSource);
      if (taux != null) return taux;
      
      // Si pas de cache, retourner des taux par défaut
      return _tauxParDefaut(deviseSource);
    }
  }

  @override
  Future<double> obtenirTauxConversion(String deviseSource, String deviseCible) async {
    if (deviseSource == deviseCible) return 1.0;
    
    final taux = await obtenirTaux(deviseSource);
    return taux[deviseCible] ?? 1.0;
  }

  Future<bool> _verifierCache() async {
    final prefs = await SharedPreferences.getInstance();
    final dateCache = prefs.getString(_cleCacheDate);
    
    if (dateCache == null) return false;
    
    final date = DateTime.parse(dateCache);
    final maintenant = DateTime.now();
    
    return maintenant.difference(date) < _dureeCache;
  }

  Future<Map<String, double>?> _obtenirDepuisCache(String deviseSource) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString('${_cleCache}_$deviseSource');
    
    if (cacheJson == null) return null;
    
    final cache = json.decode(cacheJson) as Map<String, dynamic>;
    final taux = <String, double>{};
    
    for (final entry in cache.entries) {
      taux[entry.key] = (entry.value as num).toDouble();
    }
    
    return taux;
  }

  Future<void> _sauvegarderDansCache(String deviseSource, Map<String, double> taux) async {
    final prefs = await SharedPreferences.getInstance();
    
    final tauxJson = <String, num>{};
    for (final entry in taux.entries) {
      tauxJson[entry.key] = entry.value;
    }
    
    await prefs.setString('${_cleCache}_$deviseSource', json.encode(tauxJson));
    await prefs.setString(_cleCacheDate, DateTime.now().toIso8601String());
  }

  Map<String, double> _tauxParDefaut(String deviseSource) {
    // Taux par défaut en cas d'erreur réseau et pas de cache
    final tauxDefaut = {
      'XOF': {'USD': 0.0012, 'EUR': 0.0011, 'GBP': 0.00095, 'CNY': 0.0085, 'XAF': 1.0},
      'XAF': {'USD': 0.0012, 'EUR': 0.0011, 'GBP': 0.00095, 'CNY': 0.0085, 'XOF': 1.0},
      'USD': {'XOF': 830.0, 'XAF': 830.0, 'EUR': 0.92, 'GBP': 0.79, 'CNY': 7.1},
      'EUR': {'XOF': 900.0, 'XAF': 900.0, 'USD': 1.09, 'GBP': 0.86, 'CNY': 7.7},
      'GBP': {'XOF': 1050.0, 'XAF': 1050.0, 'USD': 1.27, 'EUR': 1.16, 'CNY': 9.0},
      'CNY': {'XOF': 117.0, 'XAF': 117.0, 'USD': 0.14, 'EUR': 0.13, 'GBP': 0.11},
    };
    
    final taux = tauxDefaut[deviseSource];
    if (taux == null) return {};
    
    final resultat = <String, double>{};
    for (final entry in taux.entries) {
      resultat[entry.key] = entry.value;
    }
    
    return resultat;
  }
}
