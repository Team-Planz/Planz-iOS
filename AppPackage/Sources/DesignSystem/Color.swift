//
//  Color.swift
//
//
//  Created by 한상준 on 2023/01/28.
//

import SwiftUI

public extension PlanzDesignSystem {
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

        case subColor1
        case subColor2

        public var scale: Color {
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
            case .subColor1:
                return Color(hex: "FEDB78")
            case .subColor2:
                return Color(hex: "FF7F77")
            }
        }
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let addressable, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (addressable, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (addressable, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (addressable, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (addressable, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(addressable) / 255
        )
    }
}