import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct PlanzApp: App {
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
