import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        
    }
    
    public enum Action: Equatable {
        case onAppear
    }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}
