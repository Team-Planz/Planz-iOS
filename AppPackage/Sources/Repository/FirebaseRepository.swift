//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/10.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseFirestore
import Foundation
import Planz_iOS_Secrets
public protocol FirebaseRepository {
    func getDynamicLink(id: String?) -> URL?
}

public class FirebaseRepositoryImpl: FirebaseRepository {
    public init() {}

    private func getDeepLink(id: String?) -> URL? {
        if let id {
            return URL(string: "\(Secrets.Firebase.domain.value)/?plandId=\(id)")
        } else {
            return URL(string: Secrets.Firebase.domain.value)
        }
    }

    public func getDynamicLink(id: String? = nil) -> URL? {
        guard let link = getDeepLink(id: id) else { return nil }
        let dynamicLinksDomainURIPrefix = Secrets.Firebase.prefix.value
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Secrets.App.iosBundleId.value)
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: Secrets.App.androidBundleId.value)
        return linkBuilder?.url
    }
}
