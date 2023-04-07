//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct GradientView: View {
    public init() {}
    public var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(PDS.COLOR.purple0.scale)
                .frame(width: 20, height: 20)
            Rectangle()
                .fill(PDS.COLOR.purple3.scale)
                .frame(width: 20, height: 20)
            Rectangle()
                .fill(PDS.COLOR.purple5.scale)
                .frame(width: 20, height: 20)
            Rectangle()
                .fill(PDS.COLOR.purple7.scale)
                .frame(width: 20, height: 20)
            Rectangle()
                .fill(PDS.COLOR.purple9.scale)
                .frame(width: 20, height: 20)
        }.cornerRadius(3)
    }
}
