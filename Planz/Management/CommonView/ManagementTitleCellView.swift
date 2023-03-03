//
//  ManagementTitleCellView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI
import DesignSystem

struct ManagementTitleCellView: View {
    let title: String
    let role: RoleType
    
    var body: some View {
        HStack {
            Text(title)
                .lineLimit(1)
                .font(.title3)
                .bold()
                .foregroundColor(PColor.gray8.scale)
            RoleMarkView(role: role)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - RoleMarkView
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

struct ManagementTitleCellView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementTitleCellView(
            title: "Title",
            role: .general
        )
    }
}
