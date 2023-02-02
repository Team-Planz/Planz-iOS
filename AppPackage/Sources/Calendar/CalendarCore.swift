import ComposableArchitecture
import Foundation

public struct CalendarCore: ReducerProtocol {
    public struct State: Equatable {
        var monthStateList: IdentifiedArrayOf<MonthState> = []
        var selectedMonth: Date = .currentMonth
        
        public init() {
            
        }
    }
    
    public enum Action: Equatable {
        case onAppear
    }
    
    @Dependency(\.calendarClient) var calendarClient
    
    public init() {
        
    }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            do {
                let monthStateList = try calendarClient.createMonthStateList(-3...3, .now)
                state.monthStateList.append(contentsOf: monthStateList)
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
