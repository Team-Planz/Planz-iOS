import Dependencies
import Foundation

public struct CalendarClient {
    let createMonthStateList: (DateRange, Date) throws -> [MonthState]
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

    public static var liveValue: CalendarClient = Self { range, targetDate in
        try range
            .value
            .map {
                guard
                    let targetDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate)),
                    let month = calendar.date(byAdding: .month, value: $0, to: targetDate),
                    let monthDays = calendar.range(of: .day, in: .month, for: month)?.count,
                    let monthInLastDay = calendar.date(byAdding: .day, value: monthDays - 1, to: month),
                    let previousMonth = calendar.date(byAdding: .month, value: -1, to: month),
                    let nextMonth = calendar.date(byAdding: .month, value: 1, to: month)
                else { throw InternalError.unexpected }
                let currentMonthFirstWeekDay = calendar.component(.weekday, from: month)
                let currentMonthLastWeekDay = calendar.component(.weekday, from: monthInLastDay)

                let list = (-(currentMonthFirstWeekDay - 1) ..< (monthDays + (7 - currentMonthLastWeekDay)))
                    .compactMap { calendar.date(byAdding: .day, value: $0, to: month) }
                    .map {
                        Day(
                            date: $0,
                            isFaded: !calendar.isDate($0, equalTo: month, toGranularity: .month),
                            isToday: calendar.isDate($0, inSameDayAs: .now)
                        )
                    }

                var ranges: [Date: [Date]] = [:]
                ranges[previousMonth] = (-(currentMonthFirstWeekDay - 1) ..< 0)
                    .compactMap { calendar.date(byAdding: .day, value: $0, to: month) }
                ranges[nextMonth] = (monthDays ..< (monthDays + (7 - currentMonthLastWeekDay)))
                    .compactMap { calendar.date(byAdding: .day, value: $0, to: month) }

                return .init(id: month, days: list, ranges: ranges)
            }
    }
}

extension DependencyValues {
    var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}

let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt

    return calendar
}()
