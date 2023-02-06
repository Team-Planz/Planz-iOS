//
//  Color.swift
//
//
//  Created by 한상준 on 2023/01/28.
//

import SwiftUI

public extension PlanzDesignSystem {
    enum COLOR {
        case purple9
        case purple7
        case purple5
        case purple4
        case purple3
        case purple1
        case purple0

        case gray8
        case gray7
        case gray6
        case gray5
        case gray4
        case gray3
        case gray2
        case gray1

        case cGray2
        case cGray1

        case white3
        case white2
        case white1

        case yellow1

        case scarlet1
        case scarlet0

        public var scale: Color {
            switch self {
            case .purple9:
                return Color(hex: "6671F6")
            case .purple7:
                return Color(hex: "858DF8")
            case .purple5:
                return Color(hex: "B2B8FA")
            case .purple4:
                return Color(hex: "CED2F9")
            case .purple3:
                return Color(hex: "E0E3FD")
            case .purple1:
                return Color(hex: "E8EAFE")
            case .purple0:
                return Color(hex: "F0F1FE")
            case .gray8:
                return Color(hex: "020202")
            case .gray7:
                return Color(hex: "2D3038")
            case .gray6:
                return Color(hex: "6A707A")
            case .gray5:
                return Color(hex: "9CA3AD")
            case .gray4:
                return Color(hex: "CDD2D9")
            case .gray3:
                return Color(hex: "E8EAED")
            case .gray2:
                return Color(hex: "F3F5F8")
            case .gray1:
                return Color(hex: "F3F5F8")
            case .cGray2:
                return Color(hex: "5B687A")
            case .cGray1:
                return Color(hex: "8F9BB3")
            case .white3:
                return Color(hex: "FFFFFF")
            case .white2:
                return Color(hex: "FBFBFB")
            case .white1:
                return Color(hex: "F7F7F8")
            case .yellow1:
                return Color(hex: "FEDB78")
            case .scarlet1:
                return Color(hex: "FF7F77")
            case .scarlet0:
                return Color(hex: "FFECEB")
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
