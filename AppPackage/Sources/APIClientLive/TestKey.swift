//
//  File.swift
//
//
//  Created by junyng on 2023/03/18.
//

import APIClient
import Dependencies
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

extension APIClient: TestDependencyKey {
    public static var testValue: APIClient {
        // TODO: Set Test `AccessToken` use in server
        return .init(
            authenticate: {
                unimplemented()
            }, user: {
                unimplemented()
            }, router: { _ in
                unimplemented()
            }
        )
    }
}
