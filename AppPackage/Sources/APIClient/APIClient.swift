//
//  APIClient.swift
//
//
//  Created by junyng on 2023/02/13.
//

import ComposableArchitecture
import Foundation

public struct APIClient {
    public struct TokenEnvelope: Codable, Equatable {
        public let accessToken: String
        public let accessTokenExpiredAt: Date
        public let refreshToken: String
        public let refreshTokenExpiredAt: Date

        public init(
            accessToken: String,
            accessTokenExpiredAt: Date,
            refreshToken: String,
            refreshTokenExpiredAt: Date
        ) {
            self.accessToken = accessToken
            self.accessTokenExpiredAt = accessTokenExpiredAt
            self.refreshToken = refreshToken
            self.refreshTokenExpiredAt = refreshTokenExpiredAt
        }
    }

    public struct User: Codable {
        let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public var authenticate: @Sendable () async throws -> (TokenEnvelope)
    public var user: @Sendable () async throws -> User
    public var router: @Sendable (APIRoute) async throws -> (Data, URLResponse)

    public init(
        authenticate: @escaping @Sendable () async throws -> (TokenEnvelope),
        user: @escaping @Sendable () async throws -> User,
        router: @escaping @Sendable (APIRoute) async throws -> (Data, URLResponse)
    ) {
        self.authenticate = authenticate
        self.user = user
        self.router = router
    }

    @discardableResult
    public func request(
        route: APIRoute
    ) async throws -> (Data, URLResponse) {
        do {
            return try await router(route)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    @discardableResult
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
