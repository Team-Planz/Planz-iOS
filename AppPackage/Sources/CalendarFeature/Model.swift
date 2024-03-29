import Entity
import Foundation
import IdentifiedCollections

enum WeekDay: CaseIterable, CustomStringConvertible {
    var description: String {
        switch self {
        case .sunday:
            return "일"
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thursday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        }
    }

    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

public enum CalendarType {
    case home
    case promise
}

public enum CalendarForm {
    case `default`
    case list

    mutating func toggle() {
        self = self == .default
            ? .list
            : .default
    }
}

public struct Day: Identifiable, Equatable {
    public var id: Date { date }
    let date: Date
    public var promiseList: IdentifiedArrayOf<DayPromise> = []

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
    public let date: Date

    public init(date: Date) {
        self.date = date.month
    }
}

public struct MonthState: Identifiable, Equatable {
    public var promiseList: [DayPromise] {
        dayStateList
            .filter {
                calendar
                    .isDate(
                        $0.day.id,
                        equalTo: id.date,
                        toGranularity: .month
                    )
            }
            .flatMap(\.day.promiseList)
    }

    public let id: Month
    public var dayStateList: IdentifiedArrayOf<DayCore.State> = []

    var previousRange: ClosedRange<Int> {
        0 ... 6
    }

    var nextRange: ClosedRange<Int> {
        let count = dayStateList.count / 7
        return (7 * count - 7) ... (7 * count - 1)
    }

    public init(
        id: Date,
        dayStateList: IdentifiedArrayOf<Day>
    ) {
        self.id = Month(date: id)
        self.dayStateList = dayStateList
            .map { DayCore.State(day: $0) }
            .toIdentifiedCollection
    }
}

public struct DayPromise: Equatable, Identifiable {
    public let id: Date
    public let date: Date
    public let name: String

    init(date: Date, name: String) {
        id = date
        self.name = name
        self.date = date
    }
}
