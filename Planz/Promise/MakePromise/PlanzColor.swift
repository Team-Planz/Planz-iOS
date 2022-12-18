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
typealias Purple = PLANZ.COLOR.Purple
typealias Gray = PLANZ.COLOR.Gray
typealias CoolGray = PLANZ.COLOR.CoolGray

enum PLANZ {
    enum COLOR  {
        enum Purple: ColorScale {
            case _900
            case _700
            case _500
            case _300
            case _200
            
            var scale: Color {
                switch self {
                case ._900:
                    return Color(hex: "6671F6")
                case ._700:
                    return Color(hex: "858DF8")
                case ._500:
                    return Color(hex: "B2B8FA")
                case ._300:
                    return Color(hex: "E0E3FD")
                case ._200:
                    return Color(hex: "E8EAFE")
                }
            }
        }
        enum Gray: ColorScale {
            case _900
            case _800
            case _700
            case _500
            case _300
            case _200
            case _100

            var scale: Color {
                switch self {
                case ._900:
                    return Color(hex: "020202")
                case ._800:
                    return Color(hex: "2D3038")
                case ._700:
                    return Color(hex: "61707A")
                case ._500:
                    return Color(hex: "9CA3AD")
                case ._300:
                    return Color(hex: "CDD2D9")
                case ._200:
                    return Color(hex: "E8EAED")
                case ._100:
                    return Color(hex: "F3F5F8")
                }
            }
        }
        enum CoolGray: ColorScale {
            case _500
            case _300
            var scale: Color {
                switch self {
                case ._500:
                    return Color(hex: "5B687A")
                case ._300:
                    return Color(hex: "8F9BB#")
                }
            }
            
            
        }
        enum White: ColorScale {
            case backgroundColor1
            case backgroundColor2
            case backgroundColor3
            
            var scale: Color {
                switch self {
                case .backgroundColor1:
                    return Color(hex: "F7F7F8")
                case .backgroundColor2:
                    return Color(hex: "FBFBFB")
                case .backgroundColor3:
                    return Color(hex: "FFFFFF")
                }
            }
        }
    }
}





