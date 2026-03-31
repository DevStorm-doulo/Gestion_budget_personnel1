import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Service de préférences utilisateur
// ─────────────────────────────────────────────
class ServicePreferences {
  static final ServicePreferences _instance = ServicePreferences._internal();
  factory ServicePreferences() => _instance;
  ServicePreferences._internal();

  static const String _cleTheme = 'theme_mode';
  static const String _cleOnboardingVu = 'onboarding_vu';
  static const String _cleBiometrieActivee = 'biometrie_activee';
  static const String _cleDeviseActivee = 'devise_activee';

  late SharedPreferences _prefs;

  /// Initialise le service de préférences
  Future<void> initialiser() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Retourne le mode de thème sauvegardé
  ThemeMode obtenirTheme() {
    final themeIndex = _prefs.getInt(_cleTheme) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  /// Sauvegarde le mode de thème
  Future<void> sauvegarderTheme(ThemeMode mode) async {
    await _prefs.setInt(_cleTheme, mode.index);
  }

  /// Retourne si l'onboarding a été vu
  bool obtenirOnboardingVu() {
    return _prefs.getBool(_cleOnboardingVu) ?? false;
  }

  /// Sauvegarde que l'onboarding a été vu
  Future<void> sauvegarderOnboardingVu() async {
    await _prefs.setBool(_cleOnboardingVu, true);
  }

  /// Retourne si la biométrie est activée
  bool obtenirBiometrieActivee() {
    return _prefs.getBool(_cleBiometrieActivee) ?? false;
  }

  /// Sauvegarde l'état de la biométrie
  Future<void> sauvegarderBiometrieActivee(bool valeur) async {
    await _prefs.setBool(_cleBiometrieActivee, valeur);
  }

  /// Retourne la devise active sauvegardée
  String obtenirDeviseActive() {
    return _prefs.getString(_cleDeviseActivee) ?? 'XOF';
  }

  /// Sauvegarde la devise active
  Future<void> sauvegarderDeviseActive(String code) async {
    await _prefs.setString(_cleDeviseActivee, code);
  }
}
