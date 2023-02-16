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
        route: APIRoute,
        token: String? = nil
    ) async throws -> (Data, URLResponse) {
        do {
            var urlRequest = try await router(route)
            if let token = token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authentication")
            }
            return try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    public func request<Model: Decodable>(
        route: APIRoute,
        token: String? = nil,
        as _: Model.Type
    ) async throws -> Model {
        do {
            let (data, _) = try await request(route: route, token: token)
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

extension APIClient: DependencyKey {
    public static let liveValue = Self.init { route in
        guard let baseURLString = ProcessInfo.processInfo.environment["BASE_URL"],
              let baseURL = URL(string: baseURLString)
        else {
            fatalError()
        }

        switch route {
        case let .user(user):
            var url = baseURL
                .appendingPathComponent("api")
                .appendingPathComponent("users")
            switch user {
            case let .signup(info):
                url = url.appendingPathComponent("sign-up")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = try encode(from: info)
                return urlRequest
            case .resign:
                url = url.appendingPathComponent("resign-member")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                return urlRequest
            case let .updateName(request):
                url = url.appendingPathComponent("name")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = try encode(from: request)
                return urlRequest
            case .fetchInfo:
                url = url.appendingPathComponent("info")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            }
        case let .promising(promising):
            var url = baseURL
                .appendingPathComponent("api")
                .appendingPathComponent("promisings")
            switch promising {
            case let .create(request):
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = try encode(from: request)
                return urlRequest
            case let .fetchSession(id):
                url = url
                    .appendingPathComponent("session")
                    .appendingPathExtension("\(id)")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case let .respondTimeByHost(id, promisingTime):
                url = url
                    .appendingPathComponent("session")
                    .appendingPathComponent("\(id)")
                    .appendingPathComponent("time-response")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = try encode(from: promisingTime)
                return urlRequest
            case let .respondTimeByGuest(id, promisingTime):
                url = url
                    .appendingPathComponent("\(id)")
                    .appendingPathComponent("time-response")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = try encode(from: promisingTime)
                return urlRequest
            case let .reject(id):
                url = url
                    .appendingPathComponent("\(id)")
                    .appendingPathComponent("time-response")
                    .appendingPathComponent("rejection")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                return urlRequest
            case let .confirm(id, request):
                url = url
                    .appendingPathComponent("\(id)")
                    .appendingPathComponent("confirmation")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                return urlRequest
            case let .fetch(promisingID):
                url = url
                    .appendingPathComponent("id")
                    .appendingPathComponent("\(promisingID)")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case let .fetchStatus(promisingID):
                url = url
                    .appendingPathComponent("\(promisingID)")
                    .appendingPathComponent("status")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case .fetchAll:
                url = url
                    .appendingPathComponent("user")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case let .fetchTimeTable(promisingID):
                url = url
                    .appendingPathComponent("\(promisingID)")
                    .appendingPathComponent("time-table")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case .fetchCategories:
                url = url
                    .appendingPathComponent("categories")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            case let .randomName(categoryID):
                url = url
                    .appendingPathComponent("categories")
                    .appendingPathComponent("\(categoryID)")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            }
        case let .promise(promise):
            var url = baseURL
                .appendingPathComponent("api")
                .appendingPathComponent("promises")
            switch promise {
            case let .fetchAll(query):
                switch query {
                case .user:
                    url = url
                        .appendingPathComponent("user")
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpMethod = "GET"
                    return urlRequest
                case let .month(dateString):
                    url = url
                        .appendingPathComponent("month")
                        .appendingPathComponent("\(dateString)")
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpMethod = "GET"
                    return urlRequest
                case let .date(dateString):
                    url = url
                        .appendingPathComponent("date")
                        .appendingPathComponent("\(dateString)")
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpMethod = "GET"
                    return urlRequest
                case .today:
                    url = url
                        .appendingPathComponent("today")
                    var urlRequest = URLRequest(url: url)
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpMethod = "GET"
                    return urlRequest
                }
            case let .fetch(id):
                url = url
                    .appendingPathComponent("\(id)")
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "GET"
                return urlRequest
            }
        }
    }
}
