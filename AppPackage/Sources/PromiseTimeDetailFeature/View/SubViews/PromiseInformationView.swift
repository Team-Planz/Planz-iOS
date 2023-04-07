//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct PromiseInformationView: View {
    public init() {}

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                PromiseInformationListItem(type: .place, text: "약속 장소명")
                PromiseInformationListItem(type: .nameAndTheme, text: "파티장명 | 약속 테마명")
            }
            Spacer()
            HStack {
                PossibleUserNumberView(numberOfUser: 0)
                GradientView()
                PossibleUserNumberView(numberOfUser: 5)
            }
        }
    }
}
