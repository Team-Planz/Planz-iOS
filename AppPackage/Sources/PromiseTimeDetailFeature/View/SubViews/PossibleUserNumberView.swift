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
    let numberOfAttendee: Int
    let numberOfTotalUser: Int
    public init(numberOfAttendee: Int, numberOfTotalUser: Int) {
        self.numberOfAttendee = numberOfAttendee
        self.numberOfTotalUser = numberOfTotalUser
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("\(numberOfAttendee)/\(numberOfTotalUser)")
                .font(.system(size: 12))
                .foregroundColor(PDS.COLOR.cGray1.scale)
            Text("가능")
                .font(.system(size: 12))
                .foregroundColor(PDS.COLOR.cGray1.scale)
        }
    }
}
