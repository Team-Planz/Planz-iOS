import CasePaths
import ComposableArchitecture
import Foundation
import MakePromise

public enum Tab: CaseIterable, Equatable {
    case mainView
    case makePromise
    case promiseManagement
}

public struct HomeContainerCore: ReducerProtocol {
    public struct State: Equatable {
        var selectedTab: Tab
        @PresentationState var destinationState: DestinationState?

        public init(
            selectedTab: Tab = .mainView,
            destinationState: DestinationState? = nil
        ) {
            self.selectedTab = selectedTab
            self.destinationState = destinationState
        }
    }

    public enum Action: Equatable {
        case selectedTabChanged(tab: Tab)
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
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab: tab):
                switch tab {
                case .makePromise:
                    state.destinationState = .makePromise(.init())
                default:
                    state.selectedTab = tab
                }
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
