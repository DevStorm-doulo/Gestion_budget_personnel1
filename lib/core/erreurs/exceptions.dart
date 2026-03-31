class ExceptionServeur implements Exception {
  final String message;
  ExceptionServeur([this.message = 'Erreur serveur inconnue']);
}

class ExceptionAuthentification implements Exception {
  final String message;
  ExceptionAuthentification([this.message = 'Erreur d\'authentification']);
}

class ExceptionBiometrie implements Exception {
  final String message;
  ExceptionBiometrie([this.message = 'Erreur biométrique']);
}
