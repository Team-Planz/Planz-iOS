import ComposableArchitecture
import DesignSystem
import HomeConatinerFeature
import LoginFeature
import SwiftUI

public struct AppView: View {
    let store: StoreOf<AppCore>
    @ObservedObject var viewStore: ViewStore<Void, ViewAction>

    public init(store: StoreOf<AppCore>) {
        self.store = store
        viewStore = ViewStore(
            store
                .scope(
                    state: { _ in () },
                    action: \.reducerAction
                )
        )
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /AppCore.State.login,
                action: { AppCore.Action.login(action: $0) },
                then: LoginView.init
            )

            CaseLet(
                state: /AppCore.State.homeContainer,
                action: { AppCore.Action.homeContainer(action: $0) },
                then: HomeContainerView.init
            )

            Default {
                launchScreen
            }
        }
    }

    var launchScreen: some View {
        ZStack {
            PDS.COLOR.purple9.scale

            Image.logo
        }
        .ignoresSafeArea()
        .onAppear { viewStore.send(.onAppear) }
    }
}

extension Image {
    static let logo = Self(uiImage: .init(named: "logo", in: .module, with: nil)!)
}

extension AppView {
    enum ViewAction: Equatable {
        var reducerAction: AppCore.Action {
            switch self {
            case .onAppear:
                return .onAppear
            }
        }

        case onAppear
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .launchScreen,
                reducer: AppCore()
            )
        )
    }
}
