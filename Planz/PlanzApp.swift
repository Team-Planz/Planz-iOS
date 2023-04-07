import AppFeature
import ComposableArchitecture
import PromiseTimeDetailFeature
import SwiftUI
import TimeTableFeature
@main
struct PlanzApp: App {
    let store: StoreOf<AppCore> = .init(
        initialState: .launchScreen,
        reducer: AppCore()
    )
    let store2: StoreOf<PromiseTimeDetailFeature> = .init(initialState: .init(), reducer: PromiseTimeDetailFeature())

    var body: some Scene {
        WindowGroup {
//            AppView(store: store)
            PromiseTimeDetailView(store: store2)
        }
    }
}
