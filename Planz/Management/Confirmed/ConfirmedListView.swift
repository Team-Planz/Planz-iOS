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

struct ConfirmedModel: Identifiable {
    var id = UUID()
    let title: String
    let role: RoleType
    let names: [String]
}

// MARK: - PromiseListView
struct ConfirmedListView: View {
    @Binding var models: [ConfirmedModel]
    
    var body: some View {
        if models.isEmpty {
            NoDataView()
        } else {
            List($models) { item in
                ConfirmedCellView(item: item)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

struct ConfirmedListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedListView(models: .constant([]))
    }
}
