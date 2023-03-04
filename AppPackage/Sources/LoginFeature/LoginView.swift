//
//  LoginView.swift
//  Planz
//
//  Created by junyng on 2023/03/04.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import DesignSystem
import SwiftUI

public struct LoginView: View {
    public var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(Resource.Image.planz, bundle: Bundle.module)
                    Text(Resource.String.planz)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "8886FF"))

                    Spacer()
                }
            }
            .padding(.top, 18)
            .padding(.horizontal, 20)

            HStack(alignment: .lastTextBaseline) {
                Text(Resource.String.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(PDS.COLOR.gray8.scale)
                    .lineSpacing(8)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Text(Resource.String.browsing)
                    .underline()
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "707070"))
                    .onTapGesture {}
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)

            Spacer()

            Button {} label: {
                HStack(alignment: .center) {
                    Image(Resource.Image.kakao, bundle: Bundle.module)
                    Text(Resource.String.kakaoLogin)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(PDS.COLOR.gray7.scale)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 51)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(PDS.COLOR.yellow1.scale)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(
            ZStack {
                PDS.COLOR.white1.scale.ignoresSafeArea()
                Image(Resource.Image.mail, bundle: Bundle.module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 8)
                    .padding(.top, 5)
            }
        )
    }
}

private enum Resource {
    enum String {
        static let planz = "플랜즈"
        static let title = "친구들과 함께하는\n편리한 약속잡기"
        static let browsing = "둘러보기"
        static let kakaoLogin = "카카오 로그인"
    }

    enum Image {
        static let planz = "planz"
        static let kakao = "Kakao"
        static let mail = "mailIllustration"
    }
}

#if DEBUG
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
        }
    }
#endif
