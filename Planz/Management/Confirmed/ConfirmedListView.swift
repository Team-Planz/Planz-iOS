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

struct ConfirmedListFeature: ReducerProtocol {
    struct State: Equatable {
        var rows: IdentifiedArrayOf<ConfirmedCell.State>
        
        init(rows: IdentifiedArrayOf<ConfirmedCell.State> = []) {
            self.rows = rows
        }
    }
    
    enum Action: Equatable {
        case pushDetailView(id: ConfirmedCell.State.ID, action: ConfirmedCell.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .pushDetailView(id: let id, action: .touched):
                if let selectedData = state.rows[id: id] {
                    print(selectedData.title)
                }
                return .none
            }
        }
        .forEach(\.rows, action: /Action.pushDetailView(id:action:)) {
            ConfirmedCell()
        }
    }
}

// MARK: - PromiseListView
struct ConfirmedListView: View {
    
    let store: StoreOf<ConfirmedListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.rows.isEmpty {
                    NoDataView()
                } else {
                    List {
                        ForEachStore(self.store.scope(
                            state: \.rows,
                            action: ConfirmedListFeature.Action.pushDetailView(id: action:))) {
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
        ConfirmedListView(store: StoreOf<ConfirmedListFeature>(
            initialState: ConfirmedListFeature.State(),
            reducer: ConfirmedListFeature())
        )
    }
}
