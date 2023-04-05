//
//  StandbyPromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import CommonView
import ComposableArchitecture
import SwiftUI

public struct StandbyListFeature: ReducerProtocol {
    public struct State: Equatable {
        var rows: IdentifiedArrayOf<StandbyCell.State>
        var emptyData = EmptyDataViewFeature.State()

        init(rows: IdentifiedArrayOf<StandbyCell.State> = []) {
            self.rows = rows
        }
    }

    public enum Action: Equatable {
        case pushDetailView(id: StandbyCell.State.ID, action: StandbyCell.Action)
        case delegate(Delegate)
        case emptyData(EmptyDataViewFeature.Action)

        public enum Delegate: Equatable {
            case showDetailView(StandbyCell.State)
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .pushDetailView(id: let id, action: .touched):
                guard let selectedData = state.rows[id: id] else {
                    return .none
                }
                return .send(.delegate(.showDetailView(selectedData)))

            case .delegate:
                return .none

            case .emptyData(.delegate(.makePromise)):
                return .none

            default:
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
            if viewStore.rows.isEmpty {
                EmptyDataView(store: self.store.scope(
                    state: \.emptyData,
                    action: StandbyListFeature.Action.emptyData
                )
                )
            } else {
                List {
                    ForEachStore(self.store.scope(
                        state: \.rows,
                        action: StandbyListFeature.Action.pushDetailView(id: action:)
                    )) {
                        StandbyCellView(store: $0)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

extension IdentifiedArray where ID == StandbyCell.State.ID, Element == StandbyCell.State {
    static let mock: Self = [
        StandbyCell.State(id: UUID(), title: "약속1", role: .general, members: ["여윤정", "한지희", "김세현", "조하은", "일리윤", "이은정", "강빛나"], startDate: .now, endDate: .now + 3600, category: .init(id: 0, keyword: "keyword", type: "type"), placeName: "강남"),
        StandbyCell.State(id: UUID(), title: "약속2", role: .general, members: ["여윤정", "한지희", "김세현", "조하은"], startDate: .now, endDate: .now + 3600, category: .init(id: 0, keyword: "keyword", type: "type"), placeName: "홍대입구역"),
        StandbyCell.State(id: UUID(), title: "약속3", role: .general, members: ["한지희", "김세현", "이은정", "강빛나"], startDate: .now, endDate: .now + 3600, category: .init(id: 0, keyword: "keyword", type: "type"), placeName: "여의도")
    ]
}

struct StandbyPromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        StandbyListView(store: StoreOf<StandbyListFeature>(
            initialState: StandbyListFeature.State(rows: .mock),
            reducer: StandbyListFeature()
        ))
    }
}
