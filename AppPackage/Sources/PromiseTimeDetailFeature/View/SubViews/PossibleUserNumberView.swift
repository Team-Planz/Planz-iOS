//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct PossibleUserNumberView: View {
    let numberOfUser: Int
    public init(numberOfUser: Int) { self.numberOfUser = numberOfUser }
    public var body: some View {
        VStack(spacing: 0) {
            Text("\(numberOfUser)/5")
                .font(.system(size: 12))
                .foregroundColor(PDS.COLOR.cGray1.scale)
            Text("가능")
                .font(.system(size: 12))
                .foregroundColor(PDS.COLOR.cGray1.scale)
        }
    }
}
