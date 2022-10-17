//
//  TimeInterval+Extensions.swift
//  Planz
//
//  Created by junyng on 2022/10/11.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation

extension TimeInterval {
    func formatted(with formatter: DateComponentsFormatter) -> String {
        formatter.string(from: self) ?? .init()
    }
}

extension DateComponentsFormatter {
    static var hhmm: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}

extension TimeInterval {
    static let day: Self = 86400
    static let hour: Self = 3600
    static let min: Self = 60
}
