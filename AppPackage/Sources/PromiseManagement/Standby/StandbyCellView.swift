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
        public let id: Int
        let title: String
        let role: RoleType
        let members: [String]
        let startDate: Date
        let endDate: Date
        let category: Category
        let placeName: String

        public struct Category: Equatable {
            let id: Int
            let keyword: String
            let type: String

            public init(id: Int, keyword: String, type: String) {
                self.id = id
                self.keyword = keyword
                self.type = type
            }
        }

        public init(
            id: Int,
            title: String,
            role: RoleType,
            members: [String],
            startDate: Date,
            endDate: Date,
            category: Category,
            placeName: String
        ) {
            self.id = id
            self.title = title
            self.role = role
            self.members = members
            self.startDate = startDate
            self.endDate = endDate
            self.category = category
            self.placeName = placeName
        }
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
            namesText = state.members
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
                id: 0,
                title: "가나다라마바사아자차카파타하이",
                role: .leader,
                members: ["김세현", "한지희", "여윤정", "조하은", "이은희", "조운", "나세리", "도진우", "민지혜"],
                startDate: .now,
                endDate: .now + 3600,
                category: .init(id: 0, keyword: "keyword", type: "type"),
                placeName: "강남"
            ),
            reducer: StandbyCell()._printChanges()
        ))
    }
}
