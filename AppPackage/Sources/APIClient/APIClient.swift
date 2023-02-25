//
//  APIClient.swift
//
//
//  Created by junyng on 2023/02/13.
//

import ComposableArchitecture
import Foundation

public struct APIClient {
    public var authenticate: @Sendable () async throws -> (String)
    public var router: @Sendable (APIRoute) async throws -> (Data, URLResponse)

    public init(
        authenticate: @escaping @Sendable () async throws -> (String),
        router: @escaping @Sendable (APIRoute) async throws -> (Data, URLResponse)
    ) {
        self.authenticate = authenticate
        self.router = router
    }

    public func request(
        route: APIRoute
    ) async throws -> (Data, URLResponse) {
        do {
            return try await router(route)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    public func request<Model: Decodable>(
        route: APIRoute,
        as _: Model.Type
    ) async throws -> Model {
        do {
            let (data, _) = try await router(route)
            return try decode(as: Model.self, from: data)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }
}

private let jsonDecoder = JSONDecoder()

public func decode<Model: Decodable>(as _: Model.Type, from data: Data) throws -> Model {
    return try jsonDecoder.decode(Model.self, from: data)
}

private let jsonEncoder = JSONEncoder()

public func encode(from model: Encodable) throws -> Data {
    return try jsonEncoder.encode(model)
}
