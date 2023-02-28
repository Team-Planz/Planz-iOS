//
//  StandbyPromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import SwiftUI

struct StandbyListView: View {
    
    let store: StoreOf<PromiseManagement>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.standbyData.isEmpty {
                    NoDataView()
                } else {
                    List {
                        ForEachStore(self.store.scope(
                            state: \.standbyData,
                            action: PromiseManagement.Action.goStandbyDetailView(id: action:))) {
                                StandbyCellView(store: $0)
                            }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

struct StandbyPromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        StandbyListView(store: StoreOf<PromiseManagement>(
            initialState: PromiseManagement.State(),
            reducer: PromiseManagement()))
    }
}
