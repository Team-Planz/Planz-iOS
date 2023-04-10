//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/01.
//

import APIClient
import ComposableArchitecture
import Foundation
import Planz_iOS_Secrets
import Repository
import UIKit

public struct SharePromiseFeature: ReducerProtocol {
    let firebaseRepository: FirebaseRepository
    let kakaoRepository: KakaoRepository

    public init(
        firebaseRepository: FirebaseRepository = FirebaseRepositoryImpl(), kakaoRepository: KakaoRepository = KakaoRepositoryImpl()
    ) {
        self.firebaseRepository = firebaseRepository
        self.kakaoRepository = kakaoRepository
    }

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

    func shareViaKakao(link: String) {
        Task {
            let sharingResult = await self.kakaoRepository.getKakaoTalkSharingResult(url: link)
            do {
                let url = try sharingResult.get().url
                await UIApplication.shared.open(url)
            } catch {
                // TODO: 공유 에러 팝업 노출
                print(error)
            }
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                if let link = self.firebaseRepository.getDynamicLink(id: nil) {
                    state.linkForShare = link.absoluteString
                }
                return .none
            case .copyLinkTapped:
                UIPasteboard.general.string = state.linkForShare
                return .none
            case .shareAsKakaoTapped:
                shareViaKakao(link: state.linkForShare)
                return .none
            }
        }
    }
}
