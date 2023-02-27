//
//  PromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
        Text("No data")
    }
}

// MARK: - PromiseListView
struct ConfirmedListView: View {
    
    struct CellModel: Identifiable {
        var id = UUID()
        let title: String
        let role: RoleType
        let names: [String]
    }
    
    @Binding var models: [CellModel]
    
    var body: some View {
        if models.isEmpty {
            NoDataView()
        } else {
            List($models) { item in
                ManagementCellView(item: item)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Cell View
struct ManagementCellView: View {
    
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

struct PromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedListView(models: .constant([]))
    }
}
