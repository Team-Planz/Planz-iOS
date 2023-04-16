import APIClient
import APIClientLive
import CalendarFeature
import CasePaths
import CommonView
import ComposableArchitecture
import Foundation
import HomeFeature
import MakePromise
import SharedModel

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
        case makePromise(MakePromise.State)
        case promiseList(PromiseListCore.State)
    }

    public enum DestinationAction: Equatable {
        case makePromise(MakePromise.Action)
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

            case
                let .home(action: .todayPromiseRowTapped(date)),
                let .home(action: .calendar(action: .promiseTapped(date))):
                guard
                    let list = state.homeState.selectedMonthSchedule?.list.map(\.itemState),
                    let promise = state.homeState[date]
                else { return .none }
                state.destinationState = .promiseList(
                    .init(
                        date: promise.date,
                        promiseList: .init(uniqueElements: list),
                        selectedPromise: promise.detailViewState
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
                guard
                    let schedule = state.homeState.selectedMonthSchedule
                else { return .none }

                state.destinationState = .promiseList(
                    .init(
                        date: dayID,
                        promiseList: .init(
                            uniqueElements: schedule.list
                                .filter { calendar.isDate($0.date, equalTo: .today, toGranularity: .day) }
                                .map(\.itemState)
                        )
                    )
                )

                return .none
            case let .destination(.presented(.promiseList(.rowTapped(date)))):
//            case let .destination(.presented(.promiseList(.delegate(.selectPromise(date))))):
                guard
                    let detailViewState = state.homeState[date]?.detailViewState
                else { return .none }
                try? (/DestinationState.promiseList).modify(&state.destinationState) {
                    $0.selectedPromise = detailViewState
                }
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
                child: MakePromise.init
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
