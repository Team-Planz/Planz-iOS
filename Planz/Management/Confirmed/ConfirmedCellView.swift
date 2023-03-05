//
//  ConfirmedCellView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import DesignSystem

struct ConfirmedCell: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        let title: String
        let role: RoleType
        let leaderName: String
        let replyPeopleCount: Int
    }
    
    enum Action: Equatable {
        case touched
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .touched:
            return .none
        }
    }
}

struct ConfirmedCellView: View {
    
    let store: StoreOf<ConfirmedCell>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                HStack {
                    VStack {
                        ManagementTitleCellView(
                            title: viewStore.title,
                            role: viewStore.role
                        )
                        HStack {
                            Text(viewStore.leaderName)
                                .foregroundColor(PColor.gray5.scale)
                            Rectangle()
                                .frame(width: 1, height: 12)
                                .foregroundColor(PColor.gray5.scale)
                            Text("\(viewStore.replyPeopleCount)명 응답완료")
                                .foregroundColor(PColor.gray5.scale)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Image(systemName: "chevron.forward")
                        .frame(width: 32, height: 32)
                        .foregroundColor(PColor.gray5.scale)
                    
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
}

struct ConfirmedCellView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedCellView(store: Store(
            initialState:
                ConfirmedCell.State(
                    id: UUID(),
                    title: "가나다라마바사아자차카파타하이",
                    role: .leader,
                    leaderName: "LeaderName",
                    replyPeopleCount: 10),
            reducer: ConfirmedCell()._printChanges()))
    }
}
