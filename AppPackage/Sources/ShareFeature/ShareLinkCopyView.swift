//
//  ShareLinkCopyView.swift
//
//
//  Created by 한상준 on 2023/02/12.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ShareLinkCopyView: View {
    public let store: StoreOf<SharePromiseFeature>
    public init(store: StoreOf<SharePromiseFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                HStack {
                    Text(viewStore.linkForShare)
                        .lineLimit(1)
                    Spacer()
                    Button("복사") {
                        viewStore.send(.copyLinkTapped)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(PDS.COLOR.purple9.scale)
                }
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                .background(PDS.COLOR.white3.scale)
                .border(PDS.COLOR.gray2.scale, width: 1)
                .cornerRadius(10)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
}
