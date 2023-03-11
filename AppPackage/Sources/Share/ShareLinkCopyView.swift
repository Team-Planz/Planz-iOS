//
//  ShareLinkCopyView.swift
//
//
//  Created by 한상준 on 2023/02/12.
//

import DesignSystem
import SwiftUI

struct ShareLinkCopyView: View {
    public var body: some View {
        HStack {
            HStack {
                Text("url/link/1234/1234")
                Spacer()
                Button("복사") {}
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
