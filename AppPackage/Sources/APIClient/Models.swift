//
//  Models.swift
//
//
//  Created by junyng on 2023/02/13.
//

import Foundation

public enum SharedModels {
    public struct User: Codable {
        private enum CodingKeys: String, CodingKey {
            case id
            case name = "userName"
        }

        public let id: Int
        public let name: String
    }

    public struct UpdateUsernameRequest: Encodable {
        private enum CodingKeys: String, CodingKey {
            case username = "userName"
        }

        public let username: String

        public init(_ username: String) {
            self.username = username
        }
    }

    public struct CreatePromisingRequest: Encodable {
        private enum CodingKeys: String, CodingKey {
            case name = "promisingName"
            case startDate = "minTime"
            case endDate = "maxTime"
            case categoryID = "categoryId"
            case availableDates
            case place = "placeName"
        }

        public let name: String
        public let startDate: Date
        public let endDate: Date
        public let categoryID: Int
        public let availableDates: [Date]
        public let place: String
    }

    public struct CreatePromisingResponse: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id = "uuid"
        }

        public let id: String
    }

    public struct PromisingSessionResponse: Decodable {
        private enum CodingKeys: String, CodingKey {
            case startDate = "minTime"
            case endDate = "maxTime"
            case totalCount
            case unit
            case availableDates
        }

        public let startDate: Date
        public let endDate: Date
        public let totalCount: Int
        public let unit: Int
        public let availableDates: [Date]
    }

    public struct UpdatePromiseTimeResponse: Decodable {
        private enum CodingKeys: String, CodingKey {
            case promiseID = "id"
        }

        public let promiseID: Int
    }

    public struct TimeTable: Codable {
        let date: Date
        let times: [Bool]
    }

    public struct PromisingSessionID: Codable {
        private enum CodingKeys: String, CodingKey {
            case id = "uuid"
        }

        public let id: String

        public init(_ id: String) {
            self.id = id
        }
    }

    public struct PromisingID: Codable {
        private enum CodingKeys: String, CodingKey {
            case id = "promisingId"
        }

        public let id: String

        public init(_ id: String) {
            self.id = id
        }
    }

    public struct PromisingSession: Decodable {
        public let startDate: Date
        public let endDate: Date
        public let count: Int
        public let unit: Int
        public let availableDates: [Date]
    }

    public struct PromisingTime: Codable {
        public let unit: Int
        public let timeTable: TimeTable

        public struct TimeTable: Codable {
            public let date: Date
            public let times: [Bool]
        }
    }

    public struct ConfirmPromisingRequest: Encodable {
        public let promiseDate: Date
    }

    public struct PromisingStatusResponse: Decodable {
        public let status: Status

        public enum Status: String, Decodable {
            case owner = "OWNER"
            case confirmed = "CONFIRMED"
            case alreadyResponded = "RESPONSE_ALREADY"
            case numberLimited = "RESPONSE_MAXIMUM"
            case respondable = "RESPONSE_POSSIBLE"
        }
    }

    public struct PromisingTimeTable: Decodable {
        private enum CodingKeys: String, CodingKey {
            case members
            case colors
            case totalCount
            case unit
            case timeTable
            case id
            case promisingName
            case owner
            case startDate = "minTime"
            case endDate = "maxTime"
            case category
            case availableDates
            case placeName
        }

        public let members: [User]
        public let colors: [Int]
        public let totalCount: Int
        public let unit: Int
        public let timeTable: [Int]
        public let id: Int
        public let promisingName: String
        public let owner: [User]
        public let startDate: Date
        public let endDate: Date
        public let category: Category
        public let availableDates: [Date]
        public let placeName: String

        public struct TimeTable: Decodable {
            public let date: Date
            public let blocks: [Block]

            public struct Block: Decodable {
                public let index: Int
                public let count: Int
                public let color: Int
                public let users: [User]
            }
        }
    }

    public struct PromisingTimeStamp: Decodable {
        private enum CodingKeys: String, CodingKey {
            case updatedAt
            case isOwner
            case isResponded = "isResponsed"
            case id
            case promisingName
            case owner
            case startDate = "minTime"
            case endDate = "maxTime"
            case category
            case availableDates
            case members
            case placeName
        }

        public let updatedAt: Date
        public let isOwner: Bool
        public let isResponded: Bool
        public let id: Int
        public let promisingName: String
        public let owner: User
        public let startDate: Date
        public let endDate: Date
        public let category: Category
        public let availableDates: [Date]
        public let members: [User]
        public let placeName: String
    }

    public struct Category: Decodable {
        public let id: Int
        public let keyword: String
        public let type: String
    }

    public struct CategoryName: Decodable {
        public let name: String
    }

    public struct Promise: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case name = "promiseName"
            case date = "promiseDate"
            case owner
            case isOwner
            case category
            case members
            case place = "placeName"
        }

        public let id: Int
        public let name: String
        public let date: Date
        public let owner: User
        public let isOwner: Bool
        public let category: Category
        public let members: [User]
        public let place: String
    }
}
