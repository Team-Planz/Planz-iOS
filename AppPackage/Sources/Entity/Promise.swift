import Foundation

public enum PromiseType: Equatable {
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

    public init(
        id: UUID = .init(),
        type: PromiseType,
        date: Date,
        name: String
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.name = name
    }
}
