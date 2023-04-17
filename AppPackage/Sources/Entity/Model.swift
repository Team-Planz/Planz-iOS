import Foundation

public struct User: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "userName"
    }

    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct UpdateUsernameRequest: Encodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case username = "userName"
    }

    public let username: String

    public init(_ username: String) {
        self.username = username
    }
}

public struct CreatePromisingRequest: Encodable, Equatable {
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

    public init(
        name: String,
        startDate: Date,
        endDate: Date,
        categoryID: Int,
        availableDates: [Date],
        place: String
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.categoryID = categoryID
        self.availableDates = availableDates
        self.place = place
    }
}

public struct CreatePromisingResponse: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
    }

    public let id: String

    public init(id: String) {
        self.id = id
    }
}

public struct PromisingSessionResponse: Decodable, Equatable {
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

    public init(
        startDate: Date,
        endDate: Date,
        totalCount: Int,
        unit: Int,
        availableDates: [Date]
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.totalCount = totalCount
        self.unit = unit
        self.availableDates = availableDates
    }
}

public struct UpdatePromiseTimeResponse: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case promiseID = "id"
    }

    public let promiseID: Int

    public init(promiseID: Int) {
        self.promiseID = promiseID
    }
}

public struct TimeTable: Codable, Equatable {
    let date: Date
    let times: [Bool]

    public init(date: Date, times: [Bool]) {
        self.date = date
        self.times = times
    }
}

public struct PromisingSessionID: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
    }

    public let id: String

    public init(_ id: String) {
        self.id = id
    }
}

public struct PromisingID: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id = "promisingId"
    }

    public let id: String

    public init(_ id: String) {
        self.id = id
    }
}

public struct PromisingSession: Codable, Equatable {
    public let startDate: Date
    public let endDate: Date
    public let count: Int
    public let unit: Int
    public let availableDates: [Date]

    public init(
        startDate: Date,
        endDate: Date,
        count: Int,
        unit: Int,
        availableDates: [Date]
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.count = count
        self.unit = unit
        self.availableDates = availableDates
    }
}

public struct PromisingTime: Codable, Equatable {
    public let unit: Int
    public let timeTable: TimeTable

    public struct TimeTable: Codable, Equatable {
        public let date: Date
        public let times: [Bool]
    }
}

public struct ConfirmPromisingRequest: Encodable, Equatable {
    public let promiseDate: Date

    public init(promiseDate: Date) {
        self.promiseDate = promiseDate
    }
}

public struct PromisingStatusResponse: Codable, Equatable {
    public let status: Status

    public enum Status: String, Codable {
        case owner = "OWNER"
        case confirmed = "CONFIRMED"
        case alreadyResponded = "RESPONSE_ALREADY"
        case numberLimited = "RESPONSE_MAXIMUM"
        case respondable = "RESPONSE_POSSIBLE"
    }

    public init(status: Status) {
        self.status = status
    }
}

public struct PromisingTimeTable: Codable, Equatable {
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
    public let timeTable: TimeTable
    public let id: Int
    public let promisingName: String
    public let owner: [User]
    public let startDate: Date
    public let endDate: Date
    public let category: Category
    public let availableDates: [Date]
    public let placeName: String

    public struct TimeTable: Codable, Equatable {
        public let date: Date
        public let blocks: [Block]

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

        public init(date: Date, blocks: [Block]) {
            self.date = date
            self.blocks = blocks
        }
    }

    public init(
        members: [User],
        colors: [Int],
        totalCount: Int,
        unit: Int,
        timeTable: TimeTable,
        id: Int,
        promisingName: String,
        owner: [User],
        startDate: Date,
        endDate: Date,
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
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.availableDates = availableDates
        self.placeName = placeName
    }
}

public struct PromisingTimeStamps: Codable, Equatable {
    public let promisingTimeStamps: [PromisingTimeStamp]

    public init(_ promisingTimeStamps: [PromisingTimeStamp]) {
        self.promisingTimeStamps = promisingTimeStamps
    }
}

public struct PromisingTimeStamp: Codable, Equatable {
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

    public init(
        updatedAt: Date,
        isOwner: Bool,
        isResponded: Bool,
        id: Int,
        promisingName: String,
        owner: User,
        startDate: Date,
        endDate: Date,
        category: Category,
        availableDates: [Date],
        members: [User],
        placeName: String
    ) {
        self.updatedAt = updatedAt
        self.isOwner = isOwner
        self.isResponded = isResponded
        self.id = id
        self.promisingName = promisingName
        self.owner = owner
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.availableDates = availableDates
        self.members = members
        self.placeName = placeName
    }
}

public struct Categories: Codable, Equatable {
    public let categories: [Category]

    public init(_ categories: [Category]) {
        self.categories = categories
    }
}

public struct Category: Codable, Equatable {
    public let id: Int
    public let keyword: String
    public let type: String

    public init(id: Int, keyword: String, type: String) {
        self.id = id
        self.keyword = keyword
        self.type = type
    }
}

public struct CategoryName: Codable, Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct Promise: Codable, Equatable {
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

    public init(
        id: Int,
        name: String,
        date: Date,
        owner: User,
        isOwner: Bool,
        category: Category,
        members: [User],
        place: String
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.owner = owner
        self.isOwner = isOwner
        self.category = category
        self.members = members
        self.place = place
    }
}
