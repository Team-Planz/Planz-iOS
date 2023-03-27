import ComposableArchitecture
import SwiftUI

// MARK: - Navigation

public enum FullScreenAction<Action> {
    case dismiss
    case presented(Action)
}

extension FullScreenAction: Equatable where Action: Equatable {}

// MARK: - Reducer

extension ReducerProtocol {
    func fullScreen<ChildState, ChildAction>(
        state stateKeyPath: WritableKeyPath<State, ChildState?>,
        action actionCasePath: CasePath<Action, FullScreenAction<ChildAction>>,
        @ReducerBuilder<ChildState, ChildAction> child: () -> some ReducerProtocol<ChildState, ChildAction>
    ) -> some ReducerProtocolOf<Self> {
        let child = child()
        return Reduce { state, action in
            switch (
                state[keyPath: stateKeyPath],
                actionCasePath.extract(from: action)
            ) {
            case (_, .none):
                return self.reduce(into: &state, action: action)

            case (.none, .some(.presented)), (.none, .some(.dismiss)):
                XCTFail("A sheet action was sent while child state was nil.")
                return self.reduce(into: &state, action: action)

            case (.some(var childState), let .some(.presented(childAction))):
                let childEffects = child.reduce(into: &childState, action: childAction)
                state[keyPath: stateKeyPath] = childState
                let effects = self.reduce(into: &state, action: action)
                return .merge(
                    childEffects.map { actionCasePath.embed(.presented($0)) },
                    effects
                )

            case (.some, .some(.dismiss)):
                let effects = self.reduce(into: &state, action: action)
                state[keyPath: stateKeyPath] = nil
                return effects
            }
        }
    }
}

// MARK: - View

extension View {
    func fullScreen<ChildState: Identifiable, ChildAction>(
        store: Store<ChildState?, FullScreenAction<ChildAction>>,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        WithViewStore(store, observe: { $0?.id }) { viewStore in
            self.fullScreenCover(
                item: Binding(
                    get: { viewStore.state.map { Identified($0, id: \.self) } },
                    set: { _ in
                        if viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: returningLastNonNilValue { $0 },
                        action: FullScreenAction.presented
                    )
                ) { store in
                    child(store)
                }
            }
        }
    }
}

private func returningLastNonNilValue<A, B>(
    _ handler: @escaping (A) -> B?
) -> (A) -> B? {
    var lastValue: B?
    return { aValue in
        lastValue = handler(aValue) ?? lastValue
        return lastValue
    }
}
