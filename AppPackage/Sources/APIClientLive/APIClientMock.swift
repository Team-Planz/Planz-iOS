//
//  APIClientMock.swift
//
//
//  Created by junyng on 2023/02/25.
//

import APIClient
import ComposableArchitecture
import Entity
import Foundation

public extension APIClient {
    static var mock: Self {
        return .init(authenticate: {
            .init(
                accessToken: .init(),
                accessTokenExpiredAt: .init(),
                refreshToken: .init(),
                refreshTokenExpiredAt: .init()
            )
        }, user: {
            .init(name: "nil")
        }, router: { route in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            switch route {
            case let .user(user):
                switch user {
                case .signup:
                    fallthrough
                case .resign:
                    fallthrough
                case .updateName:
                    fallthrough
                case .fetchInfo:
                    let info = Entity.User(
                        id: 0,
                        name: "name"
                    )
                    let data = try encode(from: info)
                    return (data, URLResponse())
                }
            case let .promising(promising):
                switch promising {
                case .create:
                    fallthrough
                case .respondTimeByHost:
                    fallthrough
                case .respondTimeByGuest:
                    fallthrough
                case .reject:
                    fallthrough
                case .confirm:
                    fallthrough
                case .fetchSession:
                    let session = PromisingSession(
                        startDate: dateFormatter.date(from: "2023-02-10 09:00:00")!,
                        endDate: dateFormatter.date(from: "2023-02-20 22:00:00")!,
                        count: 0,
                        unit: 0,
                        availableDates: [
                            dateFormatter.date(from: "2023-02-15 00:00:00")!
                        ]
                    )
                    let data = try encode(from: session)
                    return (data, URLResponse())
                case .fetch:
                    let timeStamp = PromisingTimeStamp(
                        updatedAt: dateFormatter.date(from: "2023-02-10 09:00:00")!,
                        isOwner: true,
                        isResponded: true,
                        id: 0,
                        promisingName: "promising name",
                        owner: .init(id: 0, name: "name"),
                        startDate: dateFormatter.date(from: "2023-02-15 09:00:00")!,
                        endDate: dateFormatter.date(from: "2023-02-15 14:00:00")!,
                        category: .init(
                            id: 0,
                            keyword: "keyword",
                            type: "type"
                        ),
                        availableDates: [
                            dateFormatter.date(from: "2023-02-15 00:00:00")!
                        ],
                        members: [
                            .init(id: 0, name: "name")
                        ],
                        placeName: "place name"
                    )
                    let data = try encode(from: timeStamp)
                    return (data, URLResponse())
                case .fetchStatus:
                    let status = PromisingStatusResponse(status: .owner)
                    let data = try encode(from: status)
                    return (data, URLResponse())
                case .fetchTimeTable:
                    let timeTable = PromisingTimeTable(
                        members: [.init(id: 0, name: "name")],
                        colors: [0],
                        totalCount: 0,
                        unit: 0,
                        timeTable: [.init(
                            date: dateFormatter.date(from: "2023-02-15 00:00:00")!,
                            blocks: [
                                .init(
                                    index: 0,
                                    count: 0,
                                    color: 0,
                                    users: [.init(id: 0, name: "name")]
                                )
                            ]
                        )],
                        id: 0,
                        promisingName: "promising name",
                        owner: [.init(id: 0, name: "name")],
                        minTime: dateFormatter.date(from: "2023-02-15 09:00:00")!,
                        maxTime: dateFormatter.date(from: "2023-02-15 14:00:00")!,
                        category: .init(
                            id: 0,
                            keyword: "keyword",
                            type: "type"
                        ),
                        availableDates: [
                            dateFormatter.date(from: "2023-02-15 00:00:00")!
                        ],
                        placeName: "place name"
                    )
                    let data = try encode(from: timeTable)
                    return (data, URLResponse())
                case .fetchAll:
                    let timeStamps = PromisingTimeStamps(
                        [
                            PromisingTimeStamp(
                                updatedAt: dateFormatter.date(from: "2023-02-10 09:00:00")!,
                                isOwner: true,
                                isResponded: true,
                                id: 0,
                                promisingName: "promising name",
                                owner: .init(id: 0, name: "name"),
                                startDate: dateFormatter.date(from: "2023-02-15 09:00:00")!,
                                endDate: dateFormatter.date(from: "2023-02-15 14:00:00")!,
                                category: .init(
                                    id: 0,
                                    keyword: "keyword",
                                    type: "type"
                                ),
                                availableDates: [
                                    dateFormatter.date(from: "2023-02-15 00:00:00")!
                                ],
                                members: [
                                    .init(id: 0, name: "name")
                                ],
                                placeName: "place name"
                            )
                        ]
                    )
                    let data = try encode(from: timeStamps)
                    return (data, URLResponse())
                case .fetchCategories:
                    let categories = Categories(
                        [
                            Category(id: 0, keyword: "keyword", type: "type")
                        ]
                    )
                    let data = try encode(from: categories)
                    return (data, URLResponse())
                case .randomName:
                    let name = CategoryName(name: "category name")
                    let data = try encode(from: name)
                    return (data, URLResponse())
                }

            case let .promise(promise):
                switch promise {
                case let .fetchAll(query):
                    switch query {
                    case .user:
                        let confirmedPromiseList: [Promise] = [
                            .init(
                                id: 0,
                                name: "promise name",
                                date: dateFormatter.date(from: "2023-02-15 14:00:00")!,
                                owner: Entity.User(
                                    id: 0,
                                    name: "name"
                                ),
                                isOwner: false,
                                category: .init(
                                    id: 0,
                                    keyword: "keyword",
                                    type: "type"
                                ),
                                members: [
                                    .init(id: 0, name: "name1"),
                                    .init(id: 1, name: "name2")
                                ],
                                place: "place name"
                            )
                        ]
                        let data = try encode(from: confirmedPromiseList)
                        return (data, URLResponse())

                    default:
                        fatalError()
                    }
                case let .fetch(id: id):
                    let detailPromise: Promise =
                        .init(
                            id: id,
                            name: "promise name",
                            date: dateFormatter.date(from: "2023-02-15 14:00:00")!,
                            owner: Entity.User(
                                id: 0,
                                name: "name"
                            ),
                            isOwner: false,
                            category: .init(
                                id: 0,
                                keyword: "keyword",
                                type: "type"
                            ),
                            members: [
                                .init(id: 0, name: "name1"),
                                .init(id: 1, name: "name2")
                            ],
                            place: "place name"
                        )

                    let data = try encode(from: detailPromise)
                    return (data, URLResponse())
                }
            }
        })
    }
}
