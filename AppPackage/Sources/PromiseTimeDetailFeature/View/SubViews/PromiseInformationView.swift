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
                // TODO: store에서 갖고있는 참석자수, 전체 사용자 수 바인딩 해야함
                PossibleUserNumberView(numberOfAttendee: 0, numberOfTotalUser: 5)
                GradientView()
                PossibleUserNumberView(numberOfAttendee: 5, numberOfTotalUser: 5)
            }
        }
    }
}
