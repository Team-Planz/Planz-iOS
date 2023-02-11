//
//  ShareView.swift
//
//
//  Created by 한상준 on 2023/02/07.
//

import DesignSystem
import SwiftUI

public struct ShareView: View {
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
                Image(uiImage: .init(named: "mailIllustration", in: .module, with: nil)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()
            VStack(spacing: 12) {
                ShareLinkCopyView()
//                Button("카카오톡으로 약속 공유하기") {}
                Button {} label: {
                    Text("카카오톡으로 약속 공유하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(KakaoShareButtonStyle())
//                    .frame(minWidth: .infinity)
            }
        }
        .background(PDS.COLOR.white1.scale)
    }
}

struct ShareLinkCopyView: View {
    public var body: some View {
        HStack {
            HStack {
                Text("url/link/1234/1234")
                Spacer()
                Button("복사") {}
                    .font(.system(size: 14))
                    .foregroundColor(PDS.COLOR.purple9)
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .background(PDS.COLOR.white3.scale)
            .border(PDS.COLOR.gray2.scale, width: 1)
            .cornerRadius(10)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct KakaoShareButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(PDS.COLOR.gray7.scale)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(PDS.COLOR.yellow1.scale)
            )
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    }
}

#if DEBUG
    struct ShareView_Previews: PreviewProvider {
        static var previews: some View {
            ShareView()
        }
    }
#endif
