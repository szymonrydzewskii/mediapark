import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 🔥 Inicjalizacja Firebase (jeśli nie ma w main.dart)
    // FirebaseApp.configure() // ← odkomentuj, jeśli NIE używasz await Firebase.initializeApp() w Dart

    // 📲 Rejestracja dla zdalnych powiadomień
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ Sukces – otrzymano token APNs
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("📱 APNs token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }

  // ❌ Błąd – nie udało się zarejestrować
  override func application(_ application: UIApplication, 
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ APNs registration failed: \(error)")
  }
}