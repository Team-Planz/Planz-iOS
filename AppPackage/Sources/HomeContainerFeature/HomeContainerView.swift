import ComposableArchitecture
import DesignSystem
import HomeFeature
import MakePromise
import SwiftUI
import SwiftUINavigation

public struct HomeContainerView: View {
    let store: StoreOf<HomeContainerCore>
    @ObservedObject var viewStore: ViewStoreOf<HomeContainerCore>

    public init(store: StoreOf<HomeContainerCore>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationStack {
            TabView(
                selection: viewStore
                    .binding(
                        get: { $0.selectedTab },
                        send: { .selectedTabChanged(tab: $0) }
                    )
            ) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    contents(tab)
                        .tabItem {
                            VStack(spacing: 4) {
                                tab.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)

                                Text(tab.description)
                            }
                        }
                        .tag(tab)
                }
            }
            .tint(PDS.COLOR.gray8.scale)
            .navigationDestination(
                store: store
                    .scope(
                        state: \.$destinationState,
                        action: HomeContainerCore.Action.destination
                    ),
                state: /HomeContainerCore.DestinationState.makePromise,
                action: HomeContainerCore.DestinationAction.makePromise,
                destination: MakePromiseView.init
            )
        }
    }

    @ViewBuilder
    private func contents(_ item: Tab) -> some View {
        switch item {
        case .home:
            HomeView(
                store: store
                    .scope(
                        state: \.homeState,
                        action: HomeContainerCore.Action.home
                    )
            )

        case .makePromise:
            Color.clear

        case .promiseManagement:
            Text("Promise")
        }
    }
}

extension Tab: CustomStringConvertible {
    public var description: String {
        switch self {
        case .home:
            return "홈"
        case .makePromise:
            return "약속 잡기"
        case .promiseManagement:
            return "약속 관리"
        }
    }

    var image: Image {
        switch self {
        case .home:
            return PDS.Icon.homeTab.image
        case .makePromise:
            return PDS.Icon.makePromiseTab.image
        case .promiseManagement:
            return PDS.Icon.promiseManagementTab.image
        }
    }
}

#if DEBUG
    struct HomeContainerView_Previews: PreviewProvider {
        static var previews: some View {
            HomeContainerView(
                store: .init(
                    initialState: .preview,
                    reducer: HomeContainerCore()
                )
            )
        }
    }
#endif
