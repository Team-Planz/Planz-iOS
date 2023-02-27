//
//  PromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct PromiseListView: View {
    
    struct CellModel: Identifiable {
        var id = UUID()
        let title: String
        let role: RoleType
        let names: [String]
    }
    
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
    }
    
    @State private var models: [CellModel] = [
        .init(title: "약속1", role: .general, names: ["A", "B", "C", "D", "E", "F", "G"])
    ]
    
    var body: some View {
        List($models) { item in
            ManagementCellView(item: item)
        }
    }
}

// MARK: - Cell View
struct ManagementCellView: View {
    
    @Binding var item: PromiseListView.CellModel
    
    var body: some View {
        VStack {
            HStack {
                Text(item.title)
                    .font(.title3)
                    .bold()
                Text(item.role.title)
            }
            Text(item.names.joined(separator: ", "))
        }
        .background(.purple)
    }
}

struct PromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        PromiseListView()
    }
}
