import AppFeature
import ComposableArchitecture
import Firebase
import ShareFeature
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        print("Colors application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
        FirebaseApp.configure()
        return true
    }
}

@main
struct PlanzApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let store: StoreOf<AppCore> = .init(
        initialState: .launchScreen,
        reducer: AppCore()
    )

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
