import 'package:flutter/material.dart';
import '../services/service_preferences.dart';

// ─────────────────────────────────────────────
// Fournisseur de thème
// ─────────────────────────────────────────────
class FournisseurTheme extends ChangeNotifier {
  final ServicePreferences _servicePreferences = ServicePreferences();
  
  ThemeMode _modeActuel = ThemeMode.system;
  
  ThemeMode get modeActuel => _modeActuel;
  
  /// Initialise le fournisseur de thème
  Future<void> initialiser() async {
    _modeActuel = _servicePreferences.obtenirTheme();
    notifyListeners();
  }
  
  /// Change le thème et sauvegarde la préférence
  Future<void> changerTheme(ThemeMode mode) async {
    _modeActuel = mode;
    await _servicePreferences.sauvegarderTheme(mode);
    notifyListeners();
  }
}
