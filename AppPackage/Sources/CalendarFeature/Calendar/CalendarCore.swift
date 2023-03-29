import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        var calendarForm: CalendarForm
        public var monthList: IdentifiedArrayOf<MonthCore.State> = []
        @BindingState public var selectedMonth: Date
        public var selectedDates: Set<Date> = []

        public init(
            calendarForm: CalendarForm = .default,
            monthList: IdentifiedArrayOf<MonthCore.State> = [],
            selectedMonth: Date = .currentMonth,
            selectedDates: Set<Date> = []
        ) {
            self.calendarForm = calendarForm
            self.monthList = monthList
            self.selectedMonth = selectedMonth
            self.selectedDates = selectedDates
        }
    }

    public enum Action: BindableAction, Equatable {
        case onAppear(type: CalendarType)
        case onDisAppear
        case scrollViewOffsetChanged(type: CalendarType, index: Int)
        case pageIndexChanged(type: CalendarType, index: Int)
        case leftSideButtonTapped
        case rightSideButtonTapped
        case formChangeButtonTapped
        case createMonthStateList(type: CalendarType, range: CalendarClient.DateRange)
        case updateMonthStateList(CalendarClient.DateRange, TaskResult<[MonthState]>)
        case month(id: MonthCore.State.ID, action: MonthCore.Action)
        case promiseTapped(Promise.ID)
        case overSelection
        case binding(BindingAction<State>)
    }

    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.mainQueue) var mainQueue

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            struct UpdateScrollViewOffsetID {}
            struct OverSelectionID {}

            switch action {
            case let .onAppear(type: calendarType):
                return .send(.createMonthStateList(type: calendarType, range: .default))

            case .onDisAppear:
                return .merge(
                    .cancel(id: UpdateScrollViewOffsetID.self),
                    .cancel(id: OverSelectionID.self)
                )

            case let .scrollViewOffsetChanged(type: calendarType, index: index):
                return .send(.pageIndexChanged(type: calendarType, index: index))
                    .debounce(
                        id: UpdateScrollViewOffsetID.self,
                        for: .seconds(0.2),
                        scheduler: mainQueue
                    )

            case let .pageIndexChanged(type: calendarType, index: index):
                state.selectedMonth = state.monthList[index].id
                let isFirstIndex = index == .zero
                let isEdgeIndex = isFirstIndex || index == (state.monthList.count - 1)
                guard isEdgeIndex else { return .none }

                return .send(
                    .createMonthStateList(
                        type: calendarType,
                        range: isFirstIndex ? .lower : .upper
                    )
                )

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

            case .formChangeButtonTapped:
                state.calendarForm.toggle()

                return .none

            case let .createMonthStateList(type: calendarType, range: range):
                do {
                    let itemList = try calendarClient
                        .createMonthStateList(calendarType, range, state.selectedMonth)
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

            case let .month(
                id: id,
                action: .delegate(action: .drag(startIndex: startIndex, endIndex: endIndex))
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
                        .month(
                            id: id,
                            action: .dragFiltered(
                                startIndex: startIndex,
                                currentRange: range
                            )
                        )
                    )
                }

                return .send(
                    .month(
                        id: id,
                        action: .dragFiltered(
                            startIndex: startIndex,
                            currentRange: range
                        )
                    )
                )

            case let .month(
                id: _,
                action: .delegate(action: .removeSelectedDates(items: dates))
            ):
                dates
                    .forEach { state.selectedDates.remove($0) }

                return .none

            case let .month(
                id: id,
                action: .delegate(action: .firstWeekDragged(type, range))
            ):
                guard
                    let count = state.monthList[id: id.previousMonth]?.monthState.dayStateList.count
                else { return .none }
                let value = ((count / 7) - 1) * 7
                let relatedRange = (range.lowerBound + value) ... (range.upperBound + value)
                return .send(
                    .month(
                        id: id.previousMonth,
                        action: type == .insert
                            ? .selectRelatedDays(relatedRange)
                            : .deSelectRelatedDays(relatedRange)
                    )
                )

            case let .month(
                id: id,
                action: .delegate(action: .lastWeekDragged(type, range))
            ):
                let relatedRange = (range.lowerBound % 7) ... (range.upperBound % 7)

                return .send(
                    .month(
                        id: id.nextMonth,
                        action: type == .insert
                            ? .selectRelatedDays(relatedRange)
                            : .deSelectRelatedDays(relatedRange)
                    )
                )

            case let .month(id: id, action: .resetGesture):
                guard
                    let monthState = state.monthList[id: id]
                else { return .none }
                monthState.selectedDates
                    .forEach { state.selectedDates.insert($0) }
                print("🐶", state.selectedDates.sorted())
                return .none

            case .month, .overSelection, .binding, .promiseTapped:
                return .none
            }
        }
        .forEach(
            \.monthList,
            action: /Action.month(id:action:),
            element: MonthCore.init
        )
    }
}

private let maximumCount = 13

#if DEBUG
    public extension CalendarCore.State {
        static let preview = Self(monthList: .mock)
    }

    extension IdentifiedArrayOf where Element == MonthCore.State {
        static var mock: IdentifiedArrayOf<MonthCore.State> {
            var result = IdentifiedArrayOf<MonthCore.State>()
            let item = try? CalendarClient.liveValue.createMonthStateList(.home, .default, .currentMonth)
            var unwrappedItem = item ?? []
            let currentMonthIndex = unwrappedItem
                .firstIndex(where: { $0.id.date == .currentMonth }) ?? .zero
            let todayIndex = unwrappedItem[currentMonthIndex].dayStateList
                .firstIndex(where: { $0.id == .today }) ?? .zero
            unwrappedItem[currentMonthIndex].dayStateList[0].day.promiseList = [
                .init(type: .meeting, date: .today, name: "모각코 🙌"),
                .init(type: .etc, date: .today, name: "YAPP 런칭 약속 👌👌👌👌"),
                .init(type: .meal, date: .today, name: "돼지파티 약속 🐷")
            ]
            
            unwrappedItem[currentMonthIndex].dayStateList[todayIndex].day.promiseList = [
                .init(type: .meeting, date: .today, name: "모각코 🙌"),
                .init(type: .etc, date: .today, name: "YAPP 런칭 약속 👌👌👌👌"),
                .init(type: .meal, date: .today, name: "돼지파티 약속 🐷"),
                .init(type: .meeting, date: .today, name: "애플 로그인 약속 🍎"),
                .init(type: .etc, date: .today, name: "🫥 🤠 🫥"),
                .init(type: .etc, date: .today, name: "🫥 🤠 🫥"),
                .init(type: .etc, date: .today, name: "🫥 🤠 🫥"),
                .init(type: .etc, date: .today, name: "🫥 🤠 🫥")
            ]
            result
                .append(
                    contentsOf: unwrappedItem
                        .map { MonthCore.State(monthState: $0) }
                )

            return result
        }
    }
#endif
