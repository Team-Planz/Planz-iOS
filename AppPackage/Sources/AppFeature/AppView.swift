import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppCore>
    @ObservedObject var viewStore: ViewStoreOf<AppCore>

    public init(store: StoreOf<AppCore>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        Text("")
    }
}
