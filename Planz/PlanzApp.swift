import AppFeature
import ComposableArchitecture
import Firebase
import KakaoSDKCommon
import ShareFeature
import SwiftUI
import Planz_iOS_Secrets

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: Secrets.Kakao.appKey.value)
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
