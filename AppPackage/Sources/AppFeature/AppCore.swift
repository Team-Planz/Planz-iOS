import ComposableArchitecture
import Foundation

public struct AppCore: ReducerProtocol {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {}

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in
            .none
        }
    }
}
