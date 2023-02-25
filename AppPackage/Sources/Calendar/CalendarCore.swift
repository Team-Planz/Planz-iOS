import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        public var monthList: IdentifiedArrayOf<MonthCore.State> = []
        public var selectedMonth: Date = .currentMonth
        
        public init() { }
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
    }
    
    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.mainQueue) var mainQueue
    let type: CalendarType
    
    public init(type: CalendarType) {
        self.type = type
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            struct UpdateScrollViewOffsetID { }
            switch action {
            case .onAppear:
                return .send(.createMonthStateList(.default))
                
            case .onDisAppear:
                return .cancel(id: UpdateScrollViewOffsetID.self)
                
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
                action: .dragEnded(startIndex: startIndex)
            ):
                guard
                    let item = state.monthList[id: state.selectedMonth],
                    let range = item.gesture.range
                else { return .none }
                
                if let range = item.gesture.temp {
                    if item.monthState.previousRange.overlaps(range) {
                        return .send(.monthAction(id: state.selectedMonth.previousMonth, action: .update(.remove, .previous, range)))
                    } else if item.monthState.nextRange.overlaps(range) {
                        return .send(.monthAction(id: state.selectedMonth.nextMonth, action: .update(.remove, .next, range)))
                    }
                } else {
                    if item.monthState.previousRange.overlaps(range) {
                         if let item2 =  range.intersection(item.monthState.previousRange) {
                             return .send(.monthAction(id: state.selectedMonth.previousMonth, action: .update(.insert, .next, item2)))
                        }
                    } else if item.monthState.nextRange.overlaps(range) {
                        if let item2 = range.intersection(item.monthState.nextRange) {
                            return .send(.monthAction(id: state.selectedMonth.nextMonth, action: .update(.insert, .previous, item2)))
                        }
                    }
                }
                
                return .none
                
            case .monthAction:
                return .none
            }
        }
        .forEach(
            \.monthList,
             action: /Action.monthAction(id:action:),
             MonthCore.init
        )
    }
}

extension Date {
    static let currentMonth: Date = {
        let components = calendar.dateComponents([.year, .month], from: .now)
        return calendar.date(from: components) ?? .now
    }()
}

extension ClosedRange where Bound == Int {
    func intersection(_ other: Self) -> Self? {
        let intersection = set.intersection(other.set)
        let item = IndexSet(intersection)
            .rangeView
            .map(\.closedRange)
            .first
        guard let result = item else { return nil }
        
        return result
    }
}
