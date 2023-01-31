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
        case pageIndexChaged(Int)
    }
    
    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.mainQueue) var mainQueue
    
    public init() { }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        struct UpdateScrollViewOffset: Hashable { }
        switch action {
        case .task:
            do {
                let monthStateList = try calendarClient.createMonthStateList(-6...6, .now)
                state.monthStateList.append(contentsOf: monthStateList)
            } catch {
                
            }
            return .none

        case let .scrollViewOffsetChanged(index):
            return .task { .pageIndexChaged(index) }
            .debounce(
                id: UpdateScrollViewOffset.self,
                for: .seconds(0.2),
                scheduler: mainQueue
            )
            
        case let .pageIndexChaged(index):
            state.selectedMonth = state.monthStateList[index].id
            do {
                if index == .zero {
                    let item = try calendarClient.createMonthStateList(-6 ... -1, state.selectedMonth)
                    state.monthStateList.insert(contentsOf: item, at: .zero)
                } else if index == state.monthStateList.count - 1 {
                    let item = try calendarClient.createMonthStateList(1 ... 6, state.selectedMonth)
                    state.monthStateList.append(contentsOf: item)
                }
            } catch {
                
            }
            
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
