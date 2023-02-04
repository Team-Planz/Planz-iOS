import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        public var monthStateList: IdentifiedArrayOf<MonthState> = []
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
    }
    
    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.mainQueue) var mainQueue
    
    public init() { }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        struct UpdateScrollViewOffsetID: Hashable { }
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
            state.selectedMonth = state.monthStateList[index].id
            let isFirstIndex = index == .zero
            guard
                isFirstIndex || index == (state.monthStateList.count - 1)
            else { return .none }
            
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
                    .createMonthStateList(range, state.selectedMonth)
                return .send(.updateMonthStateList(range, .success(itemList)))
            } catch {
                return .send(.updateMonthStateList(range, .failure(error)))
            }
            
        case let .updateMonthStateList(range, .success(itemList)):
            switch range {
            case .lower:
                state.monthStateList.insert(contentsOf: itemList, at: .zero)
            case .default, .upper:
                state.monthStateList.append(contentsOf: itemList)
            }
            return .none
            
        case .updateMonthStateList:
            return .none
        }
    }
}

extension Date {
    static let currentMonth: Date = {
        let components = calendar.dateComponents([.year, .month], from: .now)
        return calendar.date(from: components) ?? .now
    }()
}
