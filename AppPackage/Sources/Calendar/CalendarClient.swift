import Foundation

public struct CalendarClient {

    private let _startDayOfMonth: (Date) -> Date?
    private let _endDayOfMonth: (Date) -> Date?
    private let _countOfDaysInMonth: (Date) -> Int?
    private let _numberOfDay: (Date) -> Int
    private let _weekDay: (Date) -> Int
    private let _date: (Int, Date) -> Date?
    private let _isSelectedDate: (Date, Date) -> Bool

    init(
        startDayOfMonth: @escaping (Date) -> Date?,
        endDayOfMonth: @escaping (Date) -> Date?,
        countOfDaysInMonth: @escaping (Date) -> Int?,
        numberOfDays: @escaping (Date) -> Int,
        weekDay: @escaping (Date) -> Int,
        date: @escaping (Int, Date) -> Date?,
        isSelectedDate: @escaping (Date, Date) -> Bool
    ) {
        self._startDayOfMonth = startDayOfMonth
        self._endDayOfMonth = endDayOfMonth
        self._countOfDaysInMonth = countOfDaysInMonth
        self._numberOfDay = numberOfDays
        self._weekDay = weekDay
        self._date = date
        self._isSelectedDate = isSelectedDate
    }

    private func createMetaData(for date: Date) throws -> MetaData {
        guard
            let countOfDaysInMonth = _countOfDaysInMonth(date),
            let startOfMonth = _startDayOfMonth(date)
        else { throw InterError.unexpected }

        return (
            countOfDaysInMonth: countOfDaysInMonth,
            startDayOfMonth: startOfMonth,
            startDayWeekday: _weekDay(startOfMonth)
        )
    }

    private func createDay(
        offset: Int,
        for baseDate: Date,
        selectedDate: Date,
        isWithinDisplayedMonth: Bool
    ) throws -> Day {
        guard
            let date = _date(offset, baseDate)
        else { throw InterError.unexpected }

        return Day(
            date: date,
            number: _numberOfDay(date),
            isSelectedDate: _isSelectedDate(date, selectedDate),
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }

    private func createNextMonth(
        for date: Date,
        selectedDate: Date
    ) throws -> [Day] {
        guard
            let lastDayInMonth = _endDayOfMonth(date)
        else { throw InterError.unexpected }
        let extraDays = .week - _weekDay(lastDayInMonth)
        guard extraDays > .zero else { return [] }

        return try (1...extraDays)
            .map { offset in
                try createDay(
                    offset: offset,
                    for: lastDayInMonth,
                    selectedDate: selectedDate,
                    isWithinDisplayedMonth: false
                )
            }
    }
}

extension CalendarClient {
    typealias MetaData = (
        countOfDaysInMonth: Int,
        startDayOfMonth: Date,
        startDayWeekday: Int
    )

    enum InterError: Error {
        case unexpected
    }
}

public extension CalendarClient {
    static func live(calendar: Calendar = .current) -> Self {
        .init { date in
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components)
        } endDayOfMonth: { date in
            calendar.date(byAdding: DateComponents(month: 1, day: -1), to: date)
        } countOfDaysInMonth: { date in
            calendar.range(of: .day, in: .month, for: date)?.count
        } numberOfDays: { date in
            calendar.component(.day, from: date)
        } weekDay: { date in
            calendar.component(.weekday, from: date)
        } date: { offset, date in
            calendar.date(byAdding: .day, value: offset, to: date)
        } isSelectedDate: { lhs, selectedDate in
            calendar.isDate(lhs, equalTo: selectedDate, toGranularity: .day)
        }
    }

    func createMonth(
        for date: Date,
        selectedDate: Date
    ) throws -> [Day] {
        let metaData = try createMetaData(for: date)
        let endIndex = metaData.countOfDaysInMonth + metaData.startDayWeekday

        var month = try (1..<endIndex)
            .map { number in
                let isWithinDisplayedMonth = number >= metaData.startDayWeekday

                let offset = isWithinDisplayedMonth ?
                number - metaData.startDayWeekday :
                -(metaData.startDayWeekday - number)

                return try createDay(
                    offset: offset,
                    for: metaData.startDayOfMonth,
                    selectedDate: selectedDate,
                    isWithinDisplayedMonth: isWithinDisplayedMonth
                )
            }
        month += try createNextMonth(
            for: metaData.startDayOfMonth,
            selectedDate: selectedDate
        )

        return month
    }
}

private extension Int {
    static let week: Self = 7
}
