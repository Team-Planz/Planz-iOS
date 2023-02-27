//
//  ManagementView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct ManagementView: View {
    @State private var selectedIndex = 0
    private let menus = ["대기중인 약속", "확정된 약속"]
    
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
                        PromiseListView()
                            .tag(0)
                        
                        PromiseListView()
                            .tag(1)
                    }
                    .animation(.default, value: selectedIndex)
                    .background(.gray)
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
