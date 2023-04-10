//
//  SelectThemeView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct SelectThemeView: View {
    var store: StoreOf<SelectTheme>
    let listItemEdgePadding = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                ForEachStore(
                    store.scope(
                        state: \.selectThemeItems,
                        action: SelectTheme.Action.selectThemeItem(id:action:)
                    )
                ) {
                    SelectThemeItemView(store: $0)
                        .padding(listItemEdgePadding)
                }
                Spacer()
            }
            .background(Color.white)
            .task {
                viewStore.send(.task)
            }
        }
    }
}

public struct SelectThemeItem: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: Int
        let title: String
        public var isSelected: Bool

        init(
            id: Int,
            title: String,
            isSelected: Bool = false
        ) {
            self.id = id
            self.title = title
            self.isSelected = isSelected
        }
    }

    public enum Action {
        case tapped
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { _, action in
            switch action {
            case .tapped:
                return .none
            }
        }
    }
}

public struct SelectThemeItemView: View {
    var store: StoreOf<SelectThemeItem>
    let itemCornerRadius: CGFloat = 16
    let checkMarkCircle = "checkmark.circle"
    let checkmarkCircleFill = "checkmark.circle.fill"

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Text(viewStore.title)
                    .foregroundColor(
                        viewStore.isSelected ?
                            PDS.COLOR.purple9.scale :
                            PDS.COLOR.gray5.scale
                    )
                Spacer()
                Image(systemName:
                    viewStore.isSelected ?
                        checkmarkCircleFill :
                        checkMarkCircle
                )
                .foregroundColor(
                    viewStore.isSelected ?
                        PDS.COLOR.purple9.scale :
                        PDS.COLOR.gray5.scale
                )
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .background(
                viewStore.isSelected ?
                    PDS.COLOR.purple9.scale.opacity(0.15) :
                    PDS.COLOR.gray1.scale
            )
            .cornerRadius(itemCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: itemCornerRadius)
                    .stroke(
                        PDS.COLOR.purple9.scale,
                        lineWidth: viewStore.isSelected ? 0.7 : 0
                    )
            )
            .onTapGesture {
                viewStore.send(.tapped)
            }
        }
    }
}
