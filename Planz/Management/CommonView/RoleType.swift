//
//  RoleMarkView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import DesignSystem
import SwiftUI

enum RoleType: String {
    case leader
    case general

    var title: String {
        switch self {
        case .leader:
            return "파티장"
        case .general:
            return "파티원"
        }
    }

    var textColor: Color {
        switch self {
        case .leader:
            return PColor.purple9.scale
        case .general:
            return PColor.scarlet1.scale
        }
    }

    var bgColor: Color {
        switch self {
        case .leader:
            return PColor.purple1.scale
        case .general:
            return PColor.scarlet0.scale
        }
    }
}
