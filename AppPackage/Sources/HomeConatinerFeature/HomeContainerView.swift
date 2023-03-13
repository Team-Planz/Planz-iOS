import ComposableArchitecture
import DesignSystem
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
                unwrapping: viewStore.binding(\.$destinationState),
                case: /HomeContainerCore.DestinationState.makePromise
            ) { _ in
                IfLetStore(
                    store
                        .scope(
                            state: (\HomeContainerCore.State.destinationState)
                                .appending(path: /HomeContainerCore.DestinationState.makePromise)
                                .extract(from:),
                            action: { .destination(.makePromise($0)) }
                        ),
                    then: MakePromiseView.init
                )
            }
        }
    }

    @ViewBuilder
    private func contents(_ item: Tab) -> some View {
        Group {
            switch item {
            case .mainView:
                Text("MainView")

            case .makePromise:
                Color.clear

            case .promiseManagement:
                Text("Promise")
            }
        }
    }
}

extension Tab: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mainView:
            return "메인 홈"
        case .makePromise:
            return "약속 잡기"
        case .promiseManagement:
            return "약속 관리"
        }
    }

    var image: Image {
        switch self {
        case .mainView:
            return .home
        case .makePromise:
            return .handShake
        case .promiseManagement:
            return .letter
        }
    }
}

private extension Image {
    static let home = Self(uiImage: .init(named: "home", in: .module, with: nil)!)
    static let letter = Self(uiImage: .init(named: "letter", in: .module, with: nil)!)
    static let handShake = Self(uiImage: .init(named: "handShake", in: .module, with: nil)!)
}

#if DEBUG
    struct HomeContainerView_Previews: PreviewProvider {
        static var previews: some View {
            HomeContainerView(
                store: .init(
                    initialState: .init(destination: .makePromise(.init())),
                    reducer: HomeContainerCore()
                )
            )
        }
    }
#endif
