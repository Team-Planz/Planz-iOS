//
//  PromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import SwiftUI

struct NoDataView: View {
    var body: some View {
        Text("No data")
    }
}

// MARK: - PromiseListView
struct ConfirmedListView: View {
    
    let store: StoreOf<PromiseManagement>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.confirmedData.isEmpty {
                    NoDataView()
                } else {
                    List {
                        ForEachStore(self.store.scope(
                            state: \.confirmedData,
                            action: PromiseManagement.Action.goConfirmedDetailView(id: action:))) {
                                ConfirmedCellView(store: $0)
                            }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

struct ConfirmedListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedListView(store: StoreOf<PromiseManagement>(
            initialState: PromiseManagement.State(),
            reducer: PromiseManagement()))
    }
}
