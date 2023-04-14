import APIClient
import APIClientLive
import CalendarFeature
import ComposableArchitecture
import Entity
import Foundation
import SharedModel

public struct HomeCore: ReducerProtocol {
    public struct State: Equatable {
        var todayPromiseList: [PromiseItemState] {
            guard
                let promiseList = selectedMonthSchedule?.list
            else { return [] }

            return promiseList
                .filter { calendar.isDate(.today, equalTo: $0.date, toGranularity: .day) }
                .map(\.itemState)
        }

        public var selectedMonthSchedule: PromiseSchedule? {
            guard
                let promiseSchedule = promiseScheduleList[id: .init(date: calendarState.selectedMonth)]
            else { return nil }

            return promiseSchedule
        }

        public var calendarState: CalendarCore.State
        public var promiseScheduleList: IdentifiedArrayOf<PromiseSchedule>

        public init(
            calendarState: CalendarCore.State = .init(),
            promiseScheduleList: IdentifiedArrayOf<PromiseSchedule> = .init()
        ) {
            self.calendarState = calendarState
            self.promiseScheduleList = promiseScheduleList
        }

        public subscript(_ date: Date) -> Promise? {
            guard
                let promiseList = selectedMonthSchedule?.list,
                let promise = promiseList.first(where: { $0.date == date })
            else { return nil }

            return promise
        }
    }

    public enum Action: Equatable {
        case onAppear
        case todayPromiseRowTapped(Date)
        case calendar(action: CalendarCore.Action)
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Scope(
            state: \.calendarState,
            action: /Action.calendar,
            child: CalendarCore.init
        )

        Reduce<State, Action> { _, action in
            switch action {
            case .onAppear:
                return .none

            case .todayPromiseRowTapped:
                return .none

            case .calendar:
                return .none
            }
        }
    }
}

public extension HomeCore.State {
    struct PromiseSchedule: Equatable, Identifiable {
        public let id: Month
        public let list: [Promise]
    }
}

#if DEBUG
    public extension HomeCore.State {
        static let preview = Self(
            calendarState: .preview,
            promiseScheduleList: .mock
        )
    }

    extension IdentifiedArrayOf where Element == HomeCore.State.PromiseSchedule {
        static var mock: IdentifiedArrayOf<HomeCore.State.PromiseSchedule> {
            guard
                let monthState = CalendarCore.State.preview.monthList[id: .currentMonth]?.monthState,
                let list = monthState.dayStateList[id: .today]?.day.promiseList
            else { return [] }
            let item = list.enumerated()
                .map {
                    Promise(
                        id: $0.offset,
                        name: $0.element.name,
                        date: $0.element.date,
                        owner: .init(id: .zero, name: "user"),
                        isOwner: true,
                        category: .init(id: .zero, keyword: "temp", type: "temp"),
                        members: [],
                        place: "temp"
                    )
                }
            return .init(uniqueElements: [HomeCore.State.PromiseSchedule(id: .init(date: .currentMonth), list: item)])
        }
    }
#endif
