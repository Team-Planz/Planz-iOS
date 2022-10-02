//
//  Line.swift
//  Planz
//
//  Created by junyng on 2022/10/02.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI

struct Line: Shape {
    let axis: Axis
    
    func path(in rect: CGRect) -> Path {
        switch axis {
        case .horizontal:
            return Path {
                $0.move(to: .init(x: rect.minX, y: rect.midY))
                $0.addLine(to: .init(x: rect.maxX, y: rect.midY))
            }
        case .vertical:
            return Path {
                $0.move(to: .init(x: rect.midX, y: rect.minY))
                $0.addLine(to: .init(x: rect.midX, y: rect.maxY))
            }
        }
    }
}
