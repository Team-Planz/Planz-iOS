//
//  StandbyCellView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct StandbyCell: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        let title: String
        let role: RoleType
        let names: [String]
    }

    public enum Action: Equatable {
        case touched
    }

    public func reduce(into _: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .touched:
            return .none
        }
    }
}

struct StandbyCellView: View {
    let store: StoreOf<StandbyCell>

    @ObservedObject var viewStore: ViewStore<ViewState, StandbyCell.Action>

    init(store: StoreOf<StandbyCell>) {
        self.store = store
        viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }

    struct ViewState: Equatable {
        let title: String
        let namesText: String
        let role: RoleType

        init(state: StandbyCell.State) {
            title = state.title
            role = state.role
            namesText = state.names
                .sorted(by: <)
                .joined(separator: ", ")
        }
    }

    var body: some View {
        Group {
            VStack {
                ManagementTitleCellView(
                    title: viewStore.title,
                    role: viewStore.role
                )

                Text(viewStore.namesText)
                    .foregroundColor(PColor.gray5.scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(hex: "FBFCFF"))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(PColor.gray3.scale, lineWidth: 1)
        )
        .cornerRadius(12)
        .listRowSeparator(.hidden)
        .onTapGesture {
            viewStore.send(.touched)
        }
    }
}

struct StandbyCellView_Previews: PreviewProvider {
    static var previews: some View {
        StandbyCellView(store: Store(
            initialState:
            StandbyCell.State(
                id: UUID(),
                title: "가나다라마바사아자차카파타하이",
                role: .leader,
                names: ["김세현", "한지희", "여윤정", "조하은", "이은희", "조운", "나세리", "도진우", "민지혜"]
            ),
            reducer: StandbyCell()._printChanges()
        ))
    }
}
