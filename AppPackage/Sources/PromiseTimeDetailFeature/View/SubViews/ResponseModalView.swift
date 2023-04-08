//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI
import SwiftUIHelper

public struct ResponseModalView: View {
    let title: String
    let attendee: String
    public init(title: String, attendee: String) {
        self.title = title
        self.attendee = attendee
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(PDS.COLOR.purple9.scale)
                Text("파티원")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            Text(attendee)
                .font(.system(size: 12))
                .lineLimit(0)
        }
        .padding(EdgeInsets(top: 28, leading: 20, bottom: 68, trailing: 12))
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}
