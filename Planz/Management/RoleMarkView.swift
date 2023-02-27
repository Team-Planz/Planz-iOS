//
//  RoleMarkView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

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
            return .blue
        case .general:
            return .red
        }
    }
    
    var bgColor: Color {
        switch self {
        case .leader:
            return .blue.opacity(0.4)
        case .general:
            return .red.opacity(0.4)
        }
    }
}

struct RoleMarkView: View {
    let role: RoleType
    
    var body: some View {
        Text(role.title)
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
            .background(role.bgColor)
            .foregroundColor(role.textColor)
            .cornerRadius(4)
            .bold()
    }
}

struct RoleMarkView_Previews: PreviewProvider {
    static var previews: some View {
        RoleMarkView(role: .general)
    }
}
