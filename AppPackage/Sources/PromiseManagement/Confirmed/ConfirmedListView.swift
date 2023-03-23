//
//  PromiseListView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import SwiftUI

public struct ConfirmedListFeature: ReducerProtocol {
    public struct State: Equatable {
        var rows: IdentifiedArrayOf<ConfirmedCell.State>

        init(rows: IdentifiedArrayOf<ConfirmedCell.State> = []) {
            self.rows = rows
        }
    }

    public enum Action: Equatable {
        case touchedRow(id: ConfirmedCell.State.ID, action: ConfirmedCell.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case showDetailView(ConfirmedCell.State)
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .touchedRow(id: let id, action: .touched):
                if let selectedData = state.rows[id: id] {
                    return .send(.delegate(.showDetailView(selectedData)))
                }
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.rows, action: /Action.touchedRow(id:action:)) {
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
                    ManagementEmptyDataView()
                } else {
                    List {
                        ForEachStore(self.store.scope(
                            state: \.rows,
                            action: ConfirmedListFeature.Action.touchedRow(id: action:)
                        )) {
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
            id: UUID(),
            title: "확정 약속1",
            role: .general,
            leaderName: "김세현",
            replyPeopleCount: 3,
            theme: "미팅 약속",
            date: "5월 12일 오전 10시",
            place: "강남",
            participants: ["윤여정", "권지윤", "이한나", "김이정"]
        ),
        ConfirmedCell.State(
            id: UUID(),
            title: "확정 약속2",
            role: .leader,
            leaderName: "강빛나",
            replyPeopleCount: 5,
            theme: "여행 약속",
            date: "5월 21일 오후 1시",
            place: "판교",
            participants: ["이훈", "최백준"]
        ),
        ConfirmedCell.State(
            id: UUID(),
            title: "확정 약속3",
            role: .general,
            leaderName: "한지희",
            replyPeopleCount: 8,
            theme: "식사 약속",
            date: "4월 28일 오후 6시",
            place: "홍대 입구역",
            participants: ["윤인성", "진수진", "권지영, 여윤정, 이은희, 김민지, 김고은, 강민, 이철수, 신짱구"]
        )
    ]
}

struct ConfirmedListView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedListView(store: StoreOf<ConfirmedListFeature>(
            initialState: ConfirmedListFeature.State(rows: .mock),
            reducer: ConfirmedListFeature()
        )
        )
    }
}
