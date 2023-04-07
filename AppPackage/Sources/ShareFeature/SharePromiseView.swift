//
//  ShareView.swift
//
//
//  Created by 한상준 on 2023/02/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct SharePromiseView: View {
    let mailImage: String = "mailIllustration"

    public let store: StoreOf<SharePromiseFeature>

    public init(store: StoreOf<SharePromiseFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
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
                    ShareLinkCopyView(store: store)
                    Button {
                        viewStore.send(.shareAsKakaoTapped)
                    } label: {
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
            .onAppear(perform: {
                viewStore.send(.viewDidAppear)
            })
        }
    }
}

#if DEBUG
    struct ShareView_Previews: PreviewProvider {
        static var previews: some View {
            SharePromiseView(store: .init(initialState: SharePromiseFeature.State(), reducer: SharePromiseFeature()._printChanges()))
        }
    }
#endif
