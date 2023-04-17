import Entity
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

public struct PromiseItemState: Equatable, Identifiable {
    public let id: Int
    public let promiseType: PromiseType
    public let name: String
    public let date: Date

    public init(
        id: Int,
        promiseType: PromiseType,
        name: String,
        date: Date
    ) {
        self.id = id
        self.promiseType = promiseType
        self.name = name
        self.date = date
    }
}

public struct PromiseDetailViewState: Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let theme: String
    public let date: Date
    public let place: String
    public let participants: [String]

    public init(
        id: UUID,
        title: String,
        theme: String,
        date: Date,
        place: String,
        participants: [String]
    ) {
        self.id = id
        self.title = title
        self.theme = theme
        self.date = date
        self.place = place
        self.participants = participants
    }
}

public extension Promise {
    var itemState: PromiseItemState {
        .init(
            id: id,

            // MARK: - Fix promiseType

            promiseType: .etc,
            name: name,
            date: date
        )
    }

    var detailViewState: PromiseDetailViewState {
        .init(
            /// MAKR: - Fix id
            id: .init(),
            title: name,
            theme: category.keyword,
            date: date,
            place: place,
            participants: members.map(\.name)
        )
    }
}
