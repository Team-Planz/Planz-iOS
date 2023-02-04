import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        public var monthStateList: IdentifiedArrayOf<MonthState> = []
        public var selectedMonth: Date = .currentMonth
        
        public init() { }
    }
    
    public enum Action: Equatable {
        case task
        case scrollViewOffsetChanged(Int)
        case pageIndexChanged(Int)
        case leftSideButtonTapped
        case rightSideButtonTapped
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
        case .task:
            do {
                let monthStateList = try calendarClient.createMonthStateList(.default, .now)
                state.monthStateList.append(contentsOf: monthStateList)
            } catch {
                
            }
            return .none

        case let .scrollViewOffsetChanged(index):
            return .send(.pageIndexChanged(index))
            .debounce(
                id: UpdateScrollViewOffsetID.self,
                for: .seconds(0.2),
                scheduler: mainQueue
            )
            
        case let .pageIndexChanged(index):
            state.selectedMonth = state.monthStateList[index].id
            do {
                if index == .zero {
                    let item = try calendarClient.createMonthStateList(.lower, state.selectedMonth)
                    state.monthStateList.insert(contentsOf: item, at: .zero)
                } else if index == state.monthStateList.count - 1 {
                    let item = try calendarClient.createMonthStateList(.upper, state.selectedMonth)
                    state.monthStateList.append(contentsOf: item)
                }
            } catch {
                
            }
            
            return .none
            
        case .leftSideButtonTapped:
            guard
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: state.selectedMonth)
            else { return .none }
            state.selectedMonth = previousMonth
            
            return .none
            
        case .rightSideButtonTapped:
            guard
                let nextMonth = calendar.date(byAdding: .month, value: -1, to: state.selectedMonth)
            else { return .none }
            state.selectedMonth = nextMonth
            
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