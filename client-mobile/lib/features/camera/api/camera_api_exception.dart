// Darija: Had file fih exception wa7ed sghir kanst3mloh bach nwrriw l UI
// wach l'erreur mn session/auth ola mn request 3adiya.
class CameraApiException implements Exception {
  const CameraApiException(this.message, {this.sessionExpired = false});

  final String message;
  final bool sessionExpired;

  @override
  String toString() => message;
}
