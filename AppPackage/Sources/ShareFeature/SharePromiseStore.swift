//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/01.
//

import APIClient
import ComposableArchitecture
import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseFirestore
import Foundation
import KakaoSDKShare
import KakaoSDKTemplate
import Planz_iOS_Secrets
import UIKit

public struct SharePromiseFeature: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        var linkForShare = ""
        var id: Int?
        public init() {}
    }

    public enum Action: Equatable {
        case viewDidAppear
        case copyLinkTapped
        case shareAsKakaoTapped
    }

    func getDeepLink(id: String?) -> URL? {
        if let id {
            return URL(string: "\(Secrets.Firebase.domain.value)/?plandId=\(id)")
        } else {
            return URL(string: Secrets.Firebase.domain.value)
        }
    }

    func getDynamicLink(id _: String?) -> URL? {
        guard let link = getDeepLink(id: nil) else { return nil }
        let dynamicLinksDomainURIPrefix = Secrets.Firebase.prefix.value
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Secrets.App.iosBundleId.value)
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: Secrets.App.androidBundleId.value)
        return linkBuilder?.url
    }

    func shareViaKakao(url _: String) {
        if ShareApi.isKakaoTalkSharingAvailable() {
            // TODO: 이전 화면에서 전달해주는 id 값에 맞춰서 공유 링크의 파라미터로 추가하도록 수정 필요
            ShareApi.shared.shareCustom(templateId: Int64(Secrets.Kakao.templateId.value)!, templateArgs: ["": ""]) { linkResult, error in
                if let error = error {
                    print("error : \(error)")
                } else {
                    print("defaultLink(templateObject:templateJsonObject) success.")
                    guard let linkResult = linkResult else { return }
                    UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                }
            }

        } else {}
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                if let link = getDynamicLink(id: nil) {
                    state.linkForShare = link.absoluteString
                }
                return .none
            case .copyLinkTapped:
                UIPasteboard.general.string = state.linkForShare
                return .none
            case .shareAsKakaoTapped:
                shareViaKakao(url: state.linkForShare)
                return .none
            }
        }
    }
}
