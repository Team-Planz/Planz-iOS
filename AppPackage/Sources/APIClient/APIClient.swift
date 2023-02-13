//
//  APIClient.swift
//
//
//  Created by junyng on 2023/02/13.
//

import ComposableArchitecture
import Foundation

public struct APIClient {
    public let session: URLSession
    public var router: @Sendable (APIRoute) async throws -> (URLRequest)

    public func request<Model: Decodable>(
        route: APIRoute,
        as _: Model.Type
    ) async throws -> Model {
        do {
            let urlRequest = try await router(route)
            let (data, _) = try await session.data(for: urlRequest)
            return try decode(as: Model.self, from: data)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }
}

#if DEBUG
    public extension APIClient {
        static var live: Self {
            .init(session: .shared) { @Sendable route in
                let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
                switch route {
                case let .todos(index):
                    var request = URLRequest(
                        url: baseURL
                            .appendingPathComponent("todos")
                            .appendingPathComponent("\(index)")
                    )
                    request.httpMethod = "GET"
                    return request
                }
            }
        }
    }
#endif
