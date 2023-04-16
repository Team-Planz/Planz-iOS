//
//  Day+Extensions.swift
//  Planz
//
//  Created by junyng on 2022/10/11.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation

extension TimeTable.State.Day {
    func formatted(with formatter: DateFormatter) -> String {
        formatter.string(from: date)
    }
}

extension DateFormatter {
    static var dayOnly: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    static var monthAndDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

extension Array where Element == TimeTable.State.Day {
    static var weekend: Self {
        return (0 ..< 7).map { index -> Element in
            .init(date: .init(timeIntervalSinceNow: .day * TimeInterval(index)))
        }
    }
}
