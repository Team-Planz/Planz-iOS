import CalendarFeature
import ComposableArchitecture
import Foundation

public struct HomeCore: ReducerProtocol {
    public struct State: Equatable {
        var todayPromiseList: [Promise] {
            calendar.monthList[id: .currentMonth]?.monthState[.today] ?? []
        }

        public var calendar: CalendarCore.State

        public init(calendar: CalendarCore.State = .init()) {
            self.calendar = calendar
        }
    }

    public enum Action: Equatable {
        case onAppear
        case rowTapped(Date)
        case calendar(action: CalendarCore.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.calendar,
            action: /Action.calendar,
            child: CalendarCore.init
        )

        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none

            case .rowTapped:
                return .none

            case .calendar:
                return .none
            }
        }
    }
}

#if DEBUG
    public extension HomeCore.State {
        static let preview = Self(calendar: .preview)
    }
#endif
