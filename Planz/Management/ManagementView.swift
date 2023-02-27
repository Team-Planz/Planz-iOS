//
//  ManagementView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct ManagementView: View {
    private let menus = ["대기중인 약속", "확정된 약속"]
    @State private var selectedIndex = 0
    @State private var models: [ConfirmedListView.CellModel] = [
        .init(title: "약속1", role: .general, names: ["여윤정", "한지희", "김세현", "조하은", "일리윤", "이은정", "강빛나"]),
        .init(title: "약속2", role: .leader, names: ["여윤정", "한지희", "김세현", "조하은"]),
        .init(title: "약속3", role: .general, names: [ "한지희", "김세현", "이은정", "강빛나"])
    ]
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                VStack {
                    HeaderTabView(
                        activeIndex: $selectedIndex,
                        menus: menus,
                        fullWidth: geo.size.width - 40
                    )
                        
                    TabView(selection: $selectedIndex) {
                        StandbyListView()
                            .tag(0)
                        
                        ConfirmedListView(models: $models)
                            .tag(1)
                    }
                    .animation(.default, value: selectedIndex)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("약속 관리")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("Add Item")
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView()
    }
}
