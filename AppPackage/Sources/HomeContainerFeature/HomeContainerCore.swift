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
        @BindingState var destinationState: DestinationState?

        public init(
            selectedTab: Tab = .mainView,
            destinationState: DestinationState? = nil
        ) {
            self.selectedTab = selectedTab
            self.destinationState = destinationState
        }
    }

    public enum Action: BindableAction, Equatable {
        case selectedTabChanged(tab: Tab)
        case destination(DestinationAction)
        case binding(BindingAction<State>)
    }

    public enum DestinationState: Equatable {
        case makePromise(MakePromiseState)
    }

    public enum DestinationAction: Equatable {
        case makePromise(MakePromiseAction)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

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

            case .destination(.makePromise(.dismiss)):
                state.destinationState = nil
                return .none

            case .destination, .binding:
                return .none
            }
        }
        .ifLet(
            \.destinationState,
            action: /Action.destination
        ) {
            Scope(
                state: /DestinationState.makePromise,
                action: /DestinationAction.makePromise
            ) {
                Reduce(
                    makePromiseReducer,
                    environment: .init()
                )
            }
        }
    }
}
