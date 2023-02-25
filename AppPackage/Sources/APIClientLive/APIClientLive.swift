//
//  APIClientLive.swift
//
//
//  Created by junyng on 2023/02/21.
//

import APIClient
import ComposableArchitecture
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

extension APIClient: DependencyKey {
    private typealias AccessToken = String

    public static let liveValue = Self.live(
        baseURL: .init(string: "")!,
        appKey: ""
    )

    public static func live(
        baseURL: URL,
        appKey: String
    ) -> Self {
        let service = String(describing: type(of: Self.self))
        KakaoSDK.initSDK(appKey: appKey)
        return .init(authenticate: {
            let accessToken: AccessToken = try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    UserApi.shared.loginWithKakaoAccount { token, error in
                        if let error = error {
                            return continuation.resume(throwing: error)
                        }
                        return continuation.resume(returning: token?.accessToken ?? "")
                    }
                }
            }
            KeychainWrapper.set(
                item: accessToken,
                service: service,
                account: Key.accessToken
            )
            return accessToken
        }, router: { route in
            guard let accessToken = KeychainWrapper.retreive(
                AccessToken.self,
                service: service,
                account: Key.accessToken
            ) else {
                fatalError()
            }
            let urlRequest = URLRequest(
                baseURL: baseURL,
                route: route,
                headers: [
                    "Bearer \(accessToken)": "Authentication",
                    "application/json": "Content-Type"
                ]
            )
            return try await URLSession.shared.data(for: urlRequest)
        })
    }
}

private extension APIClient {
    enum Key {
        static let accessToken = "accesstoken"
    }
}

private enum KeychainWrapper {
    static func set<T: Codable>(item: T, service: String, account: String) {
        guard let encoded = try? encode(from: item) else {
            return
        }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecValueData: encoded,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ] as CFDictionary
        SecItemAdd(query, nil)
    }

    static func retreive<T: Codable>(_ type: T.Type, service: String, account: String) -> T? {
        var item: CFTypeRef?
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
        SecItemCopyMatching(query, &item)
        guard let data = item as? Data else {
            return nil
        }
        return try? decode(as: type, from: data)
    }

    static func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service
        ] as CFDictionary
        SecItemDelete(query)
    }
}

private extension APIRoute {
    var path: String {
        switch self {
        case let .user(user):
            switch user {
            case .signup:
                return "api/users/sign-up"
            case .resign:
                return "api/users/resign-member"
            case .updateName:
                return "api/users/name"
            case .fetchInfo:
                return "api/users/info"
            }
        case let .promising(promising):
            switch promising {
            case .create:
                return "api/promisings"
            case let .fetchSession(id):
                return "api/promisings/session/\(id)"
            case let .respondTimeByHost(id, _):
                return "api/promisings/session/\(id)/time-response"
            case let .respondTimeByGuest(id, _):
                return "api/promisings/\(id)/time-response"
            case let .reject(id):
                return "api/promisings/\(id)/time-response/rejection"
            case let .confirm(id, _):
                return "api/promisings/\(id)/confirmation"
            case let .fetch(promisingID):
                return "api/promisings/id/\(promisingID)"
            case let .fetchStatus(promisingID):
                return "api/promisings/\(promisingID)/status"
            case .fetchAll:
                return "api/promisings/user"
            case let .fetchTimeTable(promisingID):
                return "api/promisings/\(promisingID)/time-table"
            case .fetchCategories:
                return "api/promisings/categories"
            case let .randomName(categoryID):
                return "api/promisings/categories/\(categoryID)"
            }
        case let .promise(promise):
            switch promise {
            case let .fetchAll(query):
                switch query {
                case .user:
                    return "api/promises/user"
                case let .month(dateString):
                    return "api/promises/month/\(dateString)"
                case let .date(dateString):
                    return "api/promises/date/\(dateString)"
                case .today:
                    return "api/promises/today"
                }
            case let .fetch(id):
                return "api/promises/\(id)"
            }
        }
    }

    var httpMethod: String {
        switch self {
        case let .user(user):
            switch user {
            case .signup:
                return "POST"
            case .resign:
                return "POST"
            case .updateName:
                return "POST"
            case .fetchInfo:
                return "GET"
            }
        case let .promising(promising):
            switch promising {
            case .create:
                return "POST"
            case .fetchSession:
                return "GET"
            case .respondTimeByHost:
                return "POST"
            case .respondTimeByGuest:
                return "POST"
            case .reject:
                return "POST"
            case .confirm:
                return "POST"
            case .fetch:
                return "GET"
            case .fetchStatus:
                return "GET"
            case .fetchAll:
                return "GET"
            case .fetchTimeTable:
                return "GET"
            case .fetchCategories:
                return "GET"
            case .randomName:
                return "GET"
            }
        case .promise:
            return "GET"
        }
    }

    var httpBody: Data? {
        switch self {
        case let .user(user):
            switch user {
            case let .signup(info):
                return try? encode(from: info)
            case let .updateName(request):
                return try? encode(from: request)
            default:
                return nil
            }
        case let .promising(promising):
            switch promising {
            case let .create(request):
                return try? encode(from: request)
            case let .respondTimeByHost(_, promisingTime):
                return try? encode(from: promisingTime)
            case let .respondTimeByGuest(_, promisingTime):
                return try? encode(from: promisingTime)
            case let .confirm(_, request):
                return try? encode(from: request)
            default:
                return nil
            }
        case .promise:
            return nil
        }
    }
}

private extension URLRequest {
    init(baseURL: URL, route: APIRoute, headers: [String: String] = [:]) {
        let url = baseURL.appendingPathComponent(route.path)
        var request = URLRequest(url: url)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = route.httpMethod
        request.httpBody = route.httpBody
        self = request
    }
}
