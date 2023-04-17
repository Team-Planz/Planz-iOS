//
//  APIClientLive.swift
//
//
//  Created by junyng on 2023/02/21.
//

import APIClient
import Dependencies
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import Planz_iOS_Secrets

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient: DependencyKey {
    public static let liveValue = Self.live(
        baseURL: .init(string: Secrets.EndPoint.baseURLPath),
        kakaoAppKey: Secrets.Kakao.appKey.value
    )

    public static func live(
        baseURL: URL?,
        kakaoAppKey: String
    ) -> Self {
        let service = String(describing: type(of: self))
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        return .init(authenticate: {
            let tokenEnvelope: TokenEnvelope = try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                        if let error = error {
                            return continuation.resume(throwing: error)
                        }
                        if let oauthToken = oauthToken {
                            return continuation.resume(
                                returning: .init(
                                    accessToken: oauthToken.accessToken,
                                    accessTokenExpiredAt: oauthToken.expiredAt,
                                    refreshToken: oauthToken.refreshToken,
                                    refreshTokenExpiredAt: oauthToken.refreshTokenExpiredAt
                                )
                            )
                        }
                        return continuation.resume(
                            throwing: URLError(.userAuthenticationRequired)
                        )
                    }
                }
            }
            KeychainWrapper.set(
                item: tokenEnvelope,
                service: service,
                account: Key.token
            )
            return tokenEnvelope
        }, user: {
            guard var tokenEnvelope = KeychainWrapper.retreive(
                TokenEnvelope.self,
                service: service,
                account: Key.token
            ) else {
                throw URLError(.userAuthenticationRequired)
            }
            if tokenEnvelope.accessTokenExpiredAt < .now {
                tokenEnvelope = try await refreshToken()
                KeychainWrapper.set(
                    item: tokenEnvelope,
                    service: service,
                    account: Key.token
                )
            }
            let user: User = try await withCheckedThrowingContinuation { continuation in
                UserApi.shared.me { user, error in
                    if let error {
                        continuation.resume(throwing: error)
                    }
                    if let nickname = user?.kakaoAccount?.profile?.nickname {
                        continuation.resume(returning: .init(name: nickname))
                    }
                }
            }
            return user
        }, router: { route in
            guard var tokenEnvelope = KeychainWrapper.retreive(
                TokenEnvelope.self,
                service: service,
                account: Key.token
            ) else {
                throw URLError(.userAuthenticationRequired)
            }
            guard let baseURL = baseURL else {
                throw URLError(.badURL)
            }
            if tokenEnvelope.accessTokenExpiredAt < .now {
                tokenEnvelope = try await refreshToken()
                KeychainWrapper.set(
                    item: tokenEnvelope,
                    service: service,
                    account: Key.token
                )
            }
            let urlRequest = URLRequest(
                baseURL: baseURL,
                route: route,
                headers: [
                    "Authorization": "Bearer \(tokenEnvelope.accessToken)",
                    "Content-Type": "application/json"
                ]
            )
            return try await URLSession.shared.data(for: urlRequest)
        })
    }

    fileprivate static func refreshToken() async throws -> TokenEnvelope {
        let tokenEnvelope: TokenEnvelope = try await withCheckedThrowingContinuation { continuation in
            AuthApi.shared.refreshToken { oauthToken, error in
                if let error = error {
                    return continuation.resume(throwing: error)
                }
                if let oauthToken = oauthToken {
                    return continuation.resume(
                        returning: .init(
                            accessToken: oauthToken.accessToken,
                            accessTokenExpiredAt: oauthToken.expiredAt,
                            refreshToken: oauthToken.refreshToken,
                            refreshTokenExpiredAt: oauthToken.refreshTokenExpiredAt
                        )
                    )
                }
                return continuation.resume(
                    throwing: URLError(.userAuthenticationRequired)
                )
            }
        }
        return tokenEnvelope
    }
}

private extension APIClient {
    enum Key {
        static let token = "token"
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
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

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

    var httpMethod: HTTPMethod {
        switch self {
        case let .user(user):
            switch user {
            case .signup:
                return .post
            case .resign:
                return .post
            case .updateName:
                return .post
            case .fetchInfo:
                return .get
            }
        case let .promising(promising):
            switch promising {
            case .create:
                return .post
            case .fetchSession:
                return .get
            case .respondTimeByHost:
                return .post
            case .respondTimeByGuest:
                return .post
            case .reject:
                return .post
            case .confirm:
                return .post
            case .fetch:
                return .get
            case .fetchStatus:
                return .get
            case .fetchAll:
                return .get
            case .fetchTimeTable:
                return .get
            case .fetchCategories:
                return .get
            case .randomName:
                return .get
            }
        case .promise:
            return .get
        }
    }

    var httpBody: Data? {
        switch self {
        case let .user(user):
            switch user {
            case .signup:
                return nil
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

extension URLRequest {
    init(baseURL: URL, route: APIRoute, headers: [String: String] = [:]) {
        let url = baseURL.appendingPathComponent(route.path)
        var request = URLRequest(url: url)
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = route.httpMethod.rawValue
        request.httpBody = route.httpBody
        self = request
    }
}
