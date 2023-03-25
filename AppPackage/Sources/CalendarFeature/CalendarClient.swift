import Dependencies
import Foundation

public struct CalendarClient {
    public let createMonthStateList: (CalendarType, DateRange, Date) throws -> [MonthState]
}

extension CalendarClient: DependencyKey {
    enum InternalError: Error {
        case unexpected
    }

    public enum DateRange: Equatable {
        var value: ClosedRange<Int> {
            switch self {
            case .lower:
                return -6 ... -1

            case .default:
                return -6 ... 6

            case .upper:
                return 1 ... 6
            }
        }

        case lower
        case `default`
        case upper
    }

    public static var liveValue: CalendarClient = Self { type, range, targetDate in
        try range
            .value
            .map {
                guard
                    let targetDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate)),
                    let month = calendar.date(byAdding: .month, value: $0, to: targetDate),
                    let monthDays = calendar.range(of: .day, in: .month, for: month)?.count,
                    let monthInLastDay = calendar.date(byAdding: .day, value: monthDays - 1, to: month)
                else { throw InternalError.unexpected }
                let currentMonthFirstWeekDay = calendar.component(.weekday, from: month)
                let currentMonthLastWeekDay = calendar.component(.weekday, from: monthInLastDay)

                let list = (-(currentMonthFirstWeekDay - 1) ..< (monthDays + (7 - currentMonthLastWeekDay)))
                    .compactMap { calendar.date(byAdding: .day, value: $0, to: month) }
                    .map {
                        let isFaded = type == .home ?
                            !calendar.isDate($0, equalTo: month, toGranularity: .month)
                            : !calendar.isDate($0, equalTo: month, toGranularity: .month) || $0 < .today
                        return Day(
                            date: $0,
                            isFaded: isFaded,
                            isToday: calendar.isDate($0, inSameDayAs: .now)
                        )
                    }

                return .init(id: month, days: list)
            }
    }
}

extension DependencyValues {
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}
