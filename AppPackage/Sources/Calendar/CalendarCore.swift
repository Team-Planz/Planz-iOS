import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        public var monthList: IdentifiedArrayOf<MonthCore.State> = []
        public var selectedMonth: Date = .currentMonth
        public var selectedDates: Set<Date> = []

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case onDisAppear
        case scrollViewOffsetChanged(Int)
        case pageIndexChanged(Int)
        case leftSideButtonTapped
        case rightSideButtonTapped
        case createMonthStateList(CalendarClient.DateRange)
        case updateMonthStateList(CalendarClient.DateRange, TaskResult<[MonthState]>)
        case monthAction(id: MonthCore.State.ID, action: MonthCore.Action)
        case overSelection
    }

    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.mainQueue) var mainQueue
    let type: CalendarType

    public init(type: CalendarType) {
        self.type = type
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            struct UpdateScrollViewOffsetID {}
            struct OverSelectionID {}

            switch action {
            case .onAppear:
                return .send(.createMonthStateList(.default))

            case .onDisAppear:
                return .merge(
                    .cancel(id: UpdateScrollViewOffsetID.self),
                    .cancel(id: OverSelectionID.self)
                )

            case let .scrollViewOffsetChanged(index):
                return .send(.pageIndexChanged(index))
                    .debounce(
                        id: UpdateScrollViewOffsetID.self,
                        for: .seconds(0.2),
                        scheduler: mainQueue
                    )

            case let .pageIndexChanged(index):
                state.selectedMonth = state.monthList[index].id
                let isFirstIndex = index == .zero
                let isEdgeIndex = isFirstIndex || index == (state.monthList.count - 1)
                guard isEdgeIndex else { return .none }

                return .send(.createMonthStateList(isFirstIndex ? .lower : .upper))

            case .leftSideButtonTapped:
                let previousMonth = calendar
                    .date(byAdding: .month, value: -1, to: state.selectedMonth)
                guard let previousMonth else { return .none }
                state.selectedMonth = previousMonth

                return .none

            case .rightSideButtonTapped:
                let nextMonth = calendar
                    .date(byAdding: .month, value: 1, to: state.selectedMonth)
                guard let nextMonth else { return .none }
                state.selectedMonth = nextMonth

                return .none

            case let .createMonthStateList(range):
                do {
                    let itemList = try calendarClient
                        .createMonthStateList(type, range, state.selectedMonth)
                    return .send(.updateMonthStateList(range, .success(itemList)))
                } catch {
                    return .send(.updateMonthStateList(range, .failure(error)))
                }

            case let .updateMonthStateList(range, .success(itemList)):
                switch range {
                case .lower:
                    let monthCoreStates = itemList
                        .map { MonthCore.State(monthState: $0) }
                    state.monthList.insert(contentsOf: monthCoreStates, at: .zero)

                case .default, .upper:
                    let monthCoreStates = itemList
                        .map { MonthCore.State(monthState: $0) }
                    state.monthList.append(contentsOf: monthCoreStates)
                }
                return .none

            case .updateMonthStateList:
                return .none

            case let .monthAction(
                id: id,
                action: .drag(startIndex: startIndex, endIndex: endIndex)
            ):
                guard let item = state.monthList[id: id] else { return .none }
                let range = min(startIndex, endIndex) ... max(startIndex, endIndex)
                guard
                    item.gesture.rangeList.contains(where: { $0.contains(startIndex) })
                else {
                    guard
                        range.count + state.selectedDates.count <= maximumCount
                    else {
                        return .send(.overSelection)
                            .debounce(
                                id: OverSelectionID.self,
                                for: .seconds(0.5),
                                scheduler: mainQueue
                            )
                    }

                    return .send(
                        .monthAction(
                            id: id,
                            action: .dragFiltered(
                                startIndex: startIndex,
                                currentRange: range
                            )
                        )
                    )
                }

                return .send(
                    .monthAction(
                        id: id,
                        action: .dragFiltered(
                            startIndex: startIndex,
                            currentRange: range
                        )
                    )
                )

            case let .monthAction(id: _, action: .removeSelectedDates(items: dates)):
                dates
                    .forEach { state.selectedDates.remove($0) }

                return .none

            case let .monthAction(
                id: id,
                action: .firstWeekDraged(type, range)
            ):
                guard
                    let count = state.monthList[id: id.previousMonth]?.monthState.days.count
                else { return .none }
                let value = ((count / 7) - 1) * 7
                let relatedRange = (range.lowerBound + value) ... (range.upperBound + value)
                return .send(
                    .monthAction(
                        id: id.previousMonth,
                        action: type == .insert
                            ? .selectRelatedDays(relatedRange)
                            : .deSelectRelatedDays(relatedRange)
                    )
                )

            case let .monthAction(
                id: id,
                action: .lastWeekDraged(type, range)
            ):
                let relatedRange = (range.lowerBound % 7) ... (range.upperBound % 7)

                return .send(
                    .monthAction(
                        id: id.nextMonth,
                        action: type == .insert
                            ? .selectRelatedDays(relatedRange)
                            : .deSelectRelatedDays(relatedRange)
                    )
                )

            case let .monthAction(id: id, action: .resetGesture):
                guard
                    let monthState = state.monthList[id: id]
                else { return .none }
                monthState.selectedDates
                    .forEach { state.selectedDates.insert(item: $0) }
                print("🐶", state.selectedDates.sorted())
                return .none

            case .monthAction, .overSelection:
                return .none
            }
        }
        .forEach(
            \.monthList,
            action: /Action.monthAction(id:action:),
            element: MonthCore.init
        )
    }
}

private let maximumCount = 13
