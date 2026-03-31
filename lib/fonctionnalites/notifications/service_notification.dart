import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// ─────────────────────────────────────────────
// Service de notifications locales
// ─────────────────────────────────────────────
class ServiceNotification {
  static final ServiceNotification _instance = ServiceNotification._internal();
  factory ServiceNotification() => _instance;
  ServiceNotification._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialise = false;
  
  /// Initialise le service de notifications
  Future<void> initialiser() async {
    if (_initialise) return;
    
    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();
    
    // Configuration pour Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuration pour iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Configuration initiale
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Initialiser le plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _initialise = true;
  }
  
  /// Gère le tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Implémenter la navigation vers la page appropriée
    print('Notification tapée: ${response.payload}');
  }
  
  /// Demande les permissions de notification
  Future<bool> demanderPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      return result ?? false;
    }
    
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    
    return false;
  }
  
  /// Affiche une notification immédiate
  Future<void> afficherNotification({
    required int id,
    required String titre,
    required String corps,
    String? payload,
  }) async {
    if (!_initialise) await initialiser();
    
    const androidDetails = AndroidNotificationDetails(
      'budget_alertes',
      'Alertes Budget',
      channelDescription: 'Notifications pour les alertes de budget',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      id,
      titre,
      corps,
      details,
      payload: payload,
    );
  }
  
  /// Affiche une notification d'alerte de budget
  Future<void> afficherAlerteBudget({
    required String nomCategorie,
    required double pourcentage,
    required double montantDepense,
    required double montantLimite,
  }) async {
    final pourcentageFormate = (pourcentage * 100).toStringAsFixed(0);
    
    await afficherNotification(
      id: nomCategorie.hashCode,
      titre: '⚠️ Alerte Budget - $nomCategorie',
      corps: 'Vous avez utilisé $pourcentageFormate% de votre budget $nomCategorie '
          '(${_formaterMontant(montantDepense)} / ${_formaterMontant(montantLimite)} FCFA)',
      payload: 'budget_alerte:$nomCategorie',
    );
  }
  
  /// Planifie une notification récapitulatif mensuel
  Future<void> planifierRecapitulatifMensuel({
    required int jour,
    required int heure,
    required int minute,
  }) async {
    if (!_initialise) await initialiser();
    
    // Calculer la prochaine date de notification
    final maintenant = DateTime.now();
    var prochaineDate = DateTime(
      maintenant.year,
      maintenant.month,
      jour,
      heure,
      minute,
    );
    
    // Si la date est déjà passée ce mois-ci, passer au mois suivant
    if (prochaineDate.isBefore(maintenant)) {
      prochaineDate = DateTime(
        maintenant.year,
        maintenant.month + 1,
        jour,
        heure,
        minute,
      );
    }
    
    const androidDetails = AndroidNotificationDetails(
      'budget_recapitulatif',
      'Récapitulatif Mensuel',
      channelDescription: 'Récapitulatif mensuel de vos budgets',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      0,
      '📊 Récapitulatif Mensuel',
      'Consultez vos statistiques de budget du mois',
      tz.TZDateTime.from(prochaineDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'recapitulatif_mensuel',
    );
  }
  
  /// Annule toutes les notifications
  Future<void> annulerToutesNotifications() async {
    await _notifications.cancelAll();
  }
  
  /// Annule une notification spécifique
  Future<void> annulerNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  /// Formate un montant en FCFA
  String _formaterMontant(double montant) {
    final n = montant.abs().toInt();
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202F');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
