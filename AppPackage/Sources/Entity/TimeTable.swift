//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/20.
//

import Foundation

public struct TimeTable: Codable, Equatable {
    public let date: Date
    public let blocks: [Block]

    public init(date: Date, blocks: [Block]) {
        self.date = date
        self.blocks = blocks
    }
}
