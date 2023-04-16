import ComposableArchitecture
import Foundation
import HomeContainerFeature
import LoginFeature

public struct AppCore: ReducerProtocol {
    public enum State: Equatable {
        case launchScreen
        case login(Login.State)
        case homeContainer(HomeContainerCore.State)
    }

    public enum Action: Equatable {
        case onAppear
        case switchScene(State)
        case login(action: Login.Action)
        case homeContainer(action: HomeContainerCore.Action)
    }

    @Dependency(\.apiClient) var apiClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: /State.login,
            action: /Action.login,
            child: Login.init
        )

        Scope(
            state: /State.homeContainer,
            action: /Action.homeContainer,
            child: HomeContainerCore.init
        )

        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                return .task {
                    do {
                        _ = try await apiClient.user()
                        return .switchScene(.homeContainer(.preview))
                    } catch {
                        return .switchScene(.login(.init()))
                    }
                }
                .animation(.default)

            case let .switchScene(scene):
                state = scene
                return .none

            case .login(action: .authorizeResponse):
                state = .homeContainer(.init())
                return .none

            case .homeContainer:
                return .none

            case .login:
                return .none
            }
        }
    }
}
