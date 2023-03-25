import Foundation

let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt

    return calendar
}()

extension Date {
    public static var today: Date {
        let components = calendar.dateComponents([.year, .month, .day], from: .now)
        guard
            let date = calendar.date(from: components)
        else { return .now }

        return date
    }

    public static let currentMonth: Date = {
        let components = calendar.dateComponents([.year, .month], from: .now)
        return calendar.date(from: components) ?? .now
    }()

    var previousMonth: Date {
        guard
            let date = calendar.date(byAdding: .month, value: -1, to: month)
        else { return .now }

        return date
    }

    var month: Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        guard
            let date = calendar.date(from: components)
        else { return .now }

        return date
    }

    var nextMonth: Date {
        guard
            let date = calendar.date(byAdding: .month, value: 1, to: month)
        else { return .now }

        return date
    }
}
