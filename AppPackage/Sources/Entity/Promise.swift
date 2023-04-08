import Foundation

public enum PromiseType: Equatable, CustomStringConvertible {
    public var description: String {
        switch self {
        case .meal:
            return "식사"
        case .meeting:
            return "미팅"
        case .trip:
            return "여행"
        case .etc:
            return "기타"
        }
    }

    case meal
    case meeting
    case trip
    case etc
}

public struct Promise: Identifiable, Equatable {
    public let id: UUID
    public let type: PromiseType
    public let date: Date
    public let name: String
    public let place: String
    public let participants: [String]

    public init(
        id: UUID = .init(),
        type: PromiseType,
        date: Date,
        name: String,
        place: String,
        participants: [String]
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.name = name
        self.place = place
        self.participants = participants
    }
}
