//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/10.
//

import KakaoSDKShare
import KakaoSDKTemplate
import Planz_iOS_Secrets

public protocol KakaoRepository {
    func getKakaoTalkSharingResult(url: String) async -> Result<SharingResult, Error>
}

public enum KakaoError: Error {
    case kakaoTalkSharingInAvailable
}

public class KakaoRepositoryImpl: KakaoRepository {
    public init() {}
    public func getKakaoTalkSharingResult(url _: String) async -> Result<SharingResult, Error> {
        if ShareApi.isKakaoTalkSharingAvailable() {
            // TODO: 이전 화면에서 전달해주는 id 값에 맞춰서 공유 링크의 파라미터로 추가하도록 수정 필요
            return await withCheckedContinuation { continuation in
                ShareApi.shared.shareCustom(templateId: Int64(Secrets.Kakao.templateId.value)!, templateArgs: ["": ""]) { linkResult, error in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        guard let linkResult = linkResult else { return }
                        continuation.resume(returning: .success(linkResult))
                    }
                }
            }
        } else {
            return .failure(KakaoError.kakaoTalkSharingInAvailable)
        }
    }
}
