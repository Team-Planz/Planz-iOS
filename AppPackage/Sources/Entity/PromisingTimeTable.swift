//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/20.
//

import Foundation

public struct PromisingTimeTable: Codable, Equatable {
    public let members: [User]
    public let colors: [Int]
    public let totalCount: Int
    public let unit: Double
    public let timeTable: [TimeTable]
    public let id: Int
    public let promisingName: String
    public let owner: [User]
    public let minTime: Date
    public let maxTime: Date
    public let category: Category
    public let availableDates: [Date]
    public let placeName: String

    // TODO: 제거되어야 함
    public init() {
        let users = [
            User(id: 0, name: "andrew"),
            User(id: 1, name: "jay")
        ]
        members = users
        colors = [1, 2, 3]
        totalCount = 0
        unit = 0.5

        id = 0
        promisingName = "Mock"
        owner = users

        var calendar = Calendar.current
        calendar.timeZone = .current
        let dateAtMidnight = calendar.startOfDay(for: .now)

        var components = DateComponents()
        components.day = 1
        components.second = -1
        let dateAtEnd = calendar.date(byAdding: components, to: .now)

        minTime = dateAtMidnight
        maxTime = dateAtEnd!

        category = Category(id: 0, keyword: "ABC", type: "DEF")

        placeName = "Test place"
        let a = (0 ..< 7).map { index -> Date in
            .init(timeIntervalSinceNow: 86400 * TimeInterval(index))
        }
        timeTable = a.map {
            TimeTable(
                date: $0,
                blocks: [
                    Block(index: 0, count: 0, color: 0, users: []),
                    Block(index: 0, count: 0, color: 0, users: []),
                    Block(index: 0, count: 0, color: 0, users: []),
                    Block(index: 0, count: 0, color: 0, users: []),
                    Block(index: 0, count: 0, color: 0, users: [])
                ]
            )
        }
        availableDates = a
    }

    public init(
        members: [User],
        colors: [Int],
        totalCount: Int,
        unit: Double,
        timeTable: [TimeTable],
        id: Int,
        promisingName: String,
        owner: [User],
        minTime: Date,
        maxTime: Date,
        category: Category,
        availableDates: [Date],
        placeName: String
    ) {
        self.members = members
        self.colors = colors
        self.totalCount = totalCount
        self.unit = unit
        self.timeTable = timeTable
        self.id = id
        self.promisingName = promisingName
        self.owner = owner
        self.minTime = minTime
        self.maxTime = maxTime
        self.category = category
        self.availableDates = availableDates
        self.placeName = placeName
    }
}
