//
//  APIClient.swift
//
//
//  Created by junyng on 2023/02/13.
//

import ComposableArchitecture
import Foundation

public struct APIClient {
    public var router: @Sendable (APIRoute) async throws -> (URLRequest)

    public func request(
        route: APIRoute
    ) async throws -> (Data, URLResponse) {
        do {
            let urlRequest = try await router(route)
            return try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }
    
    public func request<Model: Decodable>(
        route: APIRoute,
        as _: Model.Type
    ) async throws -> Model {
        do {
            let (data, _) = try await request(route: route)
            return try decode(as: Model.self, from: data)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }
}

extension APIClient: DependencyKey {
    public static let liveValue = Self.init { route in
        return .init(url: URL(string: "")!)
    }
}
