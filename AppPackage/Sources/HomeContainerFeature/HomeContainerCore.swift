import CalendarFeature
import CasePaths
import ComposableArchitecture
import Foundation
import HomeFeature
import MakePromise

public enum Tab: CaseIterable, Equatable {
    case home
    case makePromise
    case promiseManagement
}

public struct HomeContainerCore: ReducerProtocol {
    public struct State: Equatable {
        var selectedTab: Tab
        var homeState: HomeCore.State
        @PresentationState var destinationState: DestinationState?

        public init(
            selectedTab: Tab = .home,
            homeState: HomeCore.State = .init(),
            destinationState: DestinationState? = nil
        ) {
            self.selectedTab = selectedTab
            self.homeState = homeState
            self.destinationState = destinationState
        }
    }

    public enum Action: Equatable {
        case selectedTabChanged(tab: Tab)
        case home(action: HomeCore.Action)
        case destination(PresentationAction<DestinationAction>)
    }

    public enum DestinationState: Equatable {
        case makePromise(MakePromiseState)
    }

    public enum DestinationAction: Equatable {
        case makePromise(MakePromiseAction)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.homeState,
            action: /HomeContainerCore.Action.home,
            child: HomeCore.init
        )

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab: tab):
                if case .makePromise = tab {
                    state.destinationState = .makePromise(.init())
                } else {
                    state.selectedTab = tab
                }

                return .none

            case .home:
                return .none

            case .destination(.presented(.makePromise(.dismiss))):
                return .send(.destination(.dismiss))

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destinationState, action: /Action.destination) {
            Scope(
                state: /DestinationState.makePromise,
                action: /DestinationAction.makePromise,
                child: {
                    Reduce(
                        makePromiseReducer,
                        environment: .init()
                    )
                }
            )
        }
    }
}

#if DEBUG
    public extension HomeContainerCore.State {
        static let preview = Self(
            selectedTab: .home,
            homeState: .preview,
            destinationState: nil
        )
    }
#endif
