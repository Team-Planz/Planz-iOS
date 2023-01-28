//
//  PlanzColor.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Planz TEMPORARY design system Implements

protocol ColorScale {
    var scale: Color { get }
}

// Planz-Design-System Color
typealias PDSColor = PLANZ.COLOR

enum PLANZ {
    enum COLOR {
        case purple900
        case purple700
        case purple500
        case purple300
        case purple200

        case gray900
        case gray800
        case gray700
        case gray500
        case gray300
        case gray200
        case gray100

        case coolGray500
        case coolGray300

        case whiteBackgroundColor1
        case whiteBackgroundColor2
        case whiteBackgroundColor3

        var scale: Color {
            switch self {
            case .purple900:
                return Color(hex: "6671F6")
            case .purple700:
                return Color(hex: "858DF8")
            case .purple500:
                return Color(hex: "B2B8FA")
            case .purple300:
                return Color(hex: "E0E3FD")
            case .purple200:
                return Color(hex: "E8EAFE")
            case .gray900:
                return Color(hex: "020202")
            case .gray800:
                return Color(hex: "2D3038")
            case .gray700:
                return Color(hex: "61707A")
            case .gray500:
                return Color(hex: "9CA3AD")
            case .gray300:
                return Color(hex: "CDD2D9")
            case .gray200:
                return Color(hex: "E8EAED")
            case .gray100:
                return Color(hex: "F3F5F8")
            case .coolGray500:
                return Color(hex: "5B687A")
            case .coolGray300:
                return Color(hex: "8F9BB#")
            case .whiteBackgroundColor1:
                return Color(hex: "F7F7F8")
            case .whiteBackgroundColor2:
                return Color(hex: "FBFBFB")
            case .whiteBackgroundColor3:
                return Color(hex: "FFFFFF")
            }
        }
    }
}
