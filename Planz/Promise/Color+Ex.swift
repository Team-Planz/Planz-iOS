//
//  Color+Ex.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI

extension Color {
    init(hex: String){
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                var int: UInt64 = 0
                Scanner(string: hex).scanHexInt64(&int)
                let a, r, g, b: UInt64
                switch hex.count {
                case 3: // RGB (12-bit)
                    (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
                case 6: // RGB (24-bit)
                    (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
                case 8: // ARGB (32-bit)
                    (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
                default:
                    (a, r, g, b) = (1, 1, 1, 0)
                }

                self.init(
                    .sRGB,
                    red: Double(r) / 255,
                    green: Double(g) / 255,
                    blue:  Double(b) / 255,
                    opacity: Double(a) / 255
                )
    }
    
    static var gray900: Color {
        Color(hex: "020202")
    }
    var gray800: Color {
        Color(hex: "2D3038")
    }
    var gray700: Color {
        Color(hex: "6A707A")
    }
    var gray500: Color {
        Color(hex: "9CA3AD")
    }
    var gray300: Color {
        Color(hex: "CDD2D9")
    }
    var gray200: Color {
        Color(hex: "E8EAED")
    }
    var gray100: Color {
        Color(hex: "F3F5F8")
    }
}
