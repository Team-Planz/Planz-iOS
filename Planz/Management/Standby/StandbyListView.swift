//
//  StandbyPromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct StandbyModel: Identifiable {
    var id = UUID()
    let title: String
    let role: RoleType
    let leaderName: String
    let replyPeopleCount: Int
}

struct StandbyListView: View {
    @Binding var models: [StandbyModel]
    
    var body: some View {
        if models.isEmpty {
            NoDataView()
        } else {
            List($models) { item in
                StandbyCellView(item: item)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

struct StandbyPromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        StandbyListView(models: .constant([
            .init(
                title: "Title-1",
                role: .general,
                leaderName: "파티장명",
                replyPeopleCount: 3)
        ]))
    }
}
