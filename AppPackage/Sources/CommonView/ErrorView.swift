//
//  ErrorView.swift
//
//
//  Created by Sujin Jin on 2023/03/15.
//

import DesignSystem
import SwiftUI

public struct ErrorView: View {
    public init() {}

    public var body: some View {
        VStack {
            PDS.Icon.illustError.image

            VStack(spacing: 4) {
                Group {
                    Text("문제가 발생했습니다.")
                    Text("다시 시도해주세요.")
                }
                .foregroundColor(PDS.COLOR.cGray1.scale)
            }
            .padding(
                EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
            )
        }
    }
}

#if DEBUG
    struct ManagementErrorView_Previews: PreviewProvider {
        static var previews: some View {
            ErrorView()
        }
    }
#endif
