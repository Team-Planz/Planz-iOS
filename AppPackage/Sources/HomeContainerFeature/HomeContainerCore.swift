import CalendarFeature
import CasePaths
import CommonView
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
        case promiseList(PromiseListCore.State)
    }

    public enum DestinationAction: Equatable {
        case makePromise(MakePromiseAction)
        case promiseList(PromiseListCore.Action)
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Scope(
            state: \.homeState,
            action: /HomeContainerCore.Action.home,
            child: HomeCore.init
        )

        Reduce<State, Action> { state, action in
            switch action {
            case let .selectedTabChanged(tab: tab):
                if case .makePromise = tab {
                    state.destinationState = .makePromise(.init())
                } else {
                    state.selectedTab = tab
                }

                return .none

            case let .home(action: .rowTapped(date)):
                guard
                    let day = state.homeState.calendar[date],
                    let firstIndex = day.promiseList.firstIndex(where: { $0.date == date })
                else { return .none }
                state.destinationState = .promiseList(
                    .init(
                        date: day.id,
                        promiseList: .init(uniqueElements: day.promiseList),
                        selectedPromise: day.promiseList[firstIndex]
                    )
                )

                return .none

            case let .home(action: .calendar(action: .promiseTapped(date, id))):
                guard
                    let day = state.homeState.calendar[date],
                    let firstIndex = day.promiseList.firstIndex(where: { $0.id == id })
                else { return .none }
                state.destinationState = .promiseList(
                    .init(
                        date: day.id,
                        promiseList: .init(uniqueElements: day.promiseList),
                        selectedPromise: day.promiseList[firstIndex]
                    )
                )
                return .none

            case let .home(
                action: .calendar(
                    action: .month(
                        id: _,
                        action: .delegate(
                            action: .day(
                                id: dayID,
                                action: .tapped
                            )
                        )
                    )
                )
            ):
                let itemList = state.homeState.calendar[dayID]?.promiseList ?? []
                state.destinationState = .promiseList(
                    .init(
                        date: dayID,
                        promiseList: .init(uniqueElements: itemList)
                    )
                )

                return .none

            case .destination(.presented(.makePromise(.dismiss))),
                 .destination(.presented(.promiseList(.delegate(.dismiss)))):
                return .send(.destination(.dismiss))

            case .destination, .home:
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

            Scope(
                state: /DestinationState.promiseList,
                action: /DestinationAction.promiseList,
                child: PromiseListCore.init
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
