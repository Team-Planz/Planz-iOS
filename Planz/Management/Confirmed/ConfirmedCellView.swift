//
//  ConfirmedCellView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct ConfirmedCellView: View {
    
    @Binding var item: ConfirmedListView.CellModel
    
    var body: some View {
        Group {
            VStack {
                HStack {
                    Text(item.title)
                        .font(.title3)
                        .bold()
                        .border(.orange)
                    RoleMarkView(role: item.role)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(.black)
                
                Text(item.names.joined(separator: ", "))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .border(.gray)
            .padding()
            .background(.gray.opacity(0.2))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct ConfirmedCellView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedCellView(item: .constant(.init(title: "Title", role: .general, names: ["A", "B", "C"])))
    }
}
