//
//  StandbyPromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import SwiftUI

struct StandbyListFeature: ReducerProtocol {
    struct State: Equatable {
        var rows: IdentifiedArrayOf<StandbyCell.State>
        
        init(rows: IdentifiedArrayOf<StandbyCell.State> = []) {
            self.rows = rows
        }
    }
    
    enum Action: Equatable {
        case pushDetailView(id: StandbyCell.State.ID, action: StandbyCell.Action)
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
        .forEach(\.rows, action: /Action.pushDetailView(id: action:)) {
            StandbyCell()
        }
    }
}

struct StandbyListView: View {
    
    let store: StoreOf<StandbyListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.rows.isEmpty {
                    NoDataView()
                } else {
                    List {
                        ForEachStore(self.store.scope(
                            state: \.rows,
                            action: StandbyListFeature.Action.pushDetailView(id: action:))) {
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
        StandbyListView(store: StoreOf<StandbyListFeature>(
            initialState: StandbyListFeature.State(),
            reducer: StandbyListFeature()))
    }
}
