//
//  MakePromiseErrorView.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MakePromiseErrorView: View {
    public var body: some View {
        VStack {
            Image("Illustration1")
            Spacer().frame(height: 12)
            Text("문제가 발생했습니다.\n다시 시도해주세요.")
            Spacer().frame(height: 14)
            RetryButton()
        }
    }
}

public struct RetryButton: View {
    let cornerRadius: CGFloat = 7
    public var body: some View {
        Button("다시 시도") {
            // TODO: (Andrew) Network 통신 기능 개발 완료시 다시 시도하는 로직 추가될 예정
            print("Button clicked")
        }
        .foregroundColor(PDS.COLOR.purple9.scale)
        .frame(width: 96, height: 34)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(PDS.COLOR.purple9.scale, lineWidth: 1)
        )
    }
}
