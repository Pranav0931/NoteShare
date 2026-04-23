/// Firebase project configuration status tracker.
///
/// How to set up:
/// 1. Create a project at https://console.firebase.google.com
/// 2. Add an Android app with package name 'com.noteshare.noteshare'
/// 3. Download google-services.json to android/app/
/// 4. Enable Authentication (Email/Password + Google)
/// 5. Create a Firestore database
/// 6. Enable Firebase Storage
class FirebaseConfig {
  static bool _initialized = false;
  static String? _error;

  /// Returns true when Firebase has been successfully initialized.
  static bool get isReady => _initialized;

  static String? get initializationError => _error;

  static void markInitialized() {
    _initialized = true;
    _error = null;
  }

  static void markInitializationFailed(Object error) {
    _initialized = false;
    _error = error.toString();
  }
}
