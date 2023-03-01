import Foundation

public enum CalendarType {
    case home
    case appointment
}

public enum TimeOrder: CaseIterable, Hashable {
    case previous
    case next
}

public struct Day: Identifiable, Hashable {
    public var id: Date { date }
    let date: Date
    var appoints: [String] = []

    //: - MARK: isFaded, isToday는 ViewState 속성이지만, 해당 자료구조를 두개를 생성하며 관리하는게 비효율적이라고 생각해서 State 자체에 종속시켰습니다.
    // isToday 같은 경우 현재 상수로 선언했지만, 추후에 앱이 켜졌을때 비교를 하는 코드를 작성하도록 하겠습니다.
    let isFaded: Bool
    let isToday: Bool
    var selectionType: ColorState = .clear
}

enum ColorState: Equatable {
    case painted
    case clear
}

public enum GestureType {
    case insert
    case remove
}

public struct Month: Hashable {
    let date: Date
    
    init(date: Date) {
        self.date = date.month
    }
}

public struct MonthState: Identifiable, Hashable {
    public let id: Month
    var days: [Day] = []
    
    var previousRange: ClosedRange<Int> {
        0 ... 6
    }
    var nextRange: ClosedRange<Int> {
        let count = days.count / 7
        return (7 * count - 7)  ... (7 * count - 1)
    }
    
    public init(
        id: Date,
        days: [Day]
    ) {
        self.id = Month(date: id)
        self.days = days
    }
}
