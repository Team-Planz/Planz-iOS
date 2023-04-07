//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct PromiseInformationListItem: View {
    public enum InformationType {
        case place
        case nameAndTheme
    }

    let type: InformationType
    let text: String
    public init(type: InformationType, text: String) {
        self.type = type
        self.text = text
    }

    public var body: some View {
        HStack {
            type == .place ? PDS.Icon.location.image : PDS.Icon.user.image
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(PDS.COLOR.cGray2.scale)
        }
    }
}
