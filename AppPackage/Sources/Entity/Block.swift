//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/20.
//

import Foundation

public struct Block: Codable, Equatable {
    public let index: Int
    public let count: Int
    public let color: Int
    public let users: [User]

    public init(
        index: Int,
        count: Int,
        color: Int,
        users: [User]
    ) {
        self.index = index
        self.count = count
        self.color = color
        self.users = users
    }
}
