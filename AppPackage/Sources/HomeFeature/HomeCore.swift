import ComposableArchitecture
import Foundation
import MakePromise
import CasePaths

public enum Tab: CaseIterable, Equatable {
    case mainView
    case makePromise
    case promiseManagement
}

public struct HomeCore: ReducerProtocol {
    public struct State: Equatable {
        var makePromiseState: MakePromiseState? {
            get {
                destination
                    .flatMap(/HomeCore.Destination.makePromise)
            }
            set {
                guard let newValue else { return }
                destination = .makePromise(newValue)
            }
        }
        
        var selectedTab: Tab
        @BindingState var destination: Destination?
        
        public init(
            selectedTab: Tab = .mainView,
            destination: Destination? = nil
        ) {
            self.selectedTab = selectedTab
            self.destination = destination
            switch destination {
            case .makePromise:
                self.selectedTab = .makePromise
            case .promiseManagement:
                self.selectedTab = .promiseManagement
            default:
                break
            }
        }
    }
    
    public enum Action: BindableAction {
        case selectedTabChanged(tab: Tab)
        case makePromiseAction(action: MakePromiseAction)
        case binding(BindingAction<State>)
    }
    
    public enum Destination: Equatable {
        case makePromise(MakePromiseState)
        case promiseManagement
    }
    
    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab: tab):
                state.selectedTab = tab
                switch tab {
                case .makePromise:
                    state.destination = .makePromise(.init())
                default:
                    break
                }
                
                return .none
                
            case .makePromiseAction(action: .dismiss):
                state.selectedTab = .mainView
                state.destination = nil
                return .none
                
            case .makePromiseAction, .binding:
                return .none
            }
        }
        .ifLet(\.makePromiseState, action: /Action.makePromiseAction) {
            Reduce(
                makePromiseReducer,
                environment: .init()
            )
        }
    }
}

private extension HomeCore.Destination {
    var tab: Tab {
        switch self {
        case .makePromise:
            return .makePromise
        case .promiseManagement:
            return .promiseManagement
        }
    }
}
