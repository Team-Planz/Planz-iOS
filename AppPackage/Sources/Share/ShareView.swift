//
//  ShareView.swift
//
//
//  Created by 한상준 on 2023/02/07.
//

import DesignSystem
import SwiftUI

public struct ShareView: View {
    let mailImage: String = "mailIllustration"
    public init() {}

    public var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: 50) {
                VStack(spacing: 6) {
                    HStack(spacing: .zero) {
                        EmptyView().frame(width: 20)
                        Text("이제 약속을 ")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Text("공유")
                            .font(.system(size: 20))
                            .foregroundColor(PDS.COLOR.purple9.scale)
                            .fontWeight(.bold)
                        Text("하세요!")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    HStack(spacing: .zero) {
                        Text("최대 10명까지 응답 가능")
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    HStack(spacing: .zero) {
                        Text("*본인포함")
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                PDS.Icon.mailIllustration.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            VStack(spacing: 12) {
                ShareLinkCopyView()
                Button {} label: {
                    HStack(spacing: 0) {
                        PDS.Icon.kakao.image
                        Text("카카오톡으로 약속 공유하기")
                            .lineLimit(1)
                    }.frame(maxWidth: .infinity)
                }
                .buttonStyle(KakaoShareButtonStyle())
            }
        }
        .background(PDS.COLOR.white1.scale)
    }
}

#if DEBUG
    struct ShareView_Previews: PreviewProvider {
        static var previews: some View {
            ShareView()
        }
    }
#endif
