import SwiftUI
import FirebaseCore

@main
struct DesiDealsApp: App {
    init() {
        setupFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupFirebase() {
        guard FirebaseApp.app() == nil else { return }
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("⚠️ Missing GoogleService-Info.plist. Firebase will not be configured.")
        }
    }
}
