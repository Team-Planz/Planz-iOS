//
//  PromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import SwiftUI

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
                    ManagementNoDataView()
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

extension IdentifiedArray where ID == ConfirmedCell.State.ID, Element == ConfirmedCell.State {
  static let mock: Self = [
    ConfirmedCell.State(
        id: UUID(), title: "확정 약속1", role: .general, leaderName: "김세현", replyPeopleCount: 3
    ),
    ConfirmedCell.State(
        id: UUID(), title: "확정 약속2", role: .leader, leaderName: "강빛나", replyPeopleCount: 5
    ),
    ConfirmedCell.State(
        id: UUID(), title: "확정 약속3", role: .general, leaderName: "한지희", replyPeopleCount: 8
    )
  ]
}

struct ConfirmedListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedListView(store: StoreOf<ConfirmedListFeature>(
            initialState: ConfirmedListFeature.State(rows: .mock),
            reducer: ConfirmedListFeature())
        )
    }
}
