//
//  KakaoShareButtonStyle.swift
//
//
//  Created by 한상준 on 2023/02/12.
//

import DesignSystem
import SwiftUI

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
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}
