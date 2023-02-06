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
    var store: Store<SelectThemeState, SelectThemeAction>
    let listItemEdgePadding = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    public var body: some View {
        VStack {
            Spacer()
            SelectThemeItemView(promiseType: .meal, store: store)
                .padding(listItemEdgePadding)
            SelectThemeItemView(promiseType: .meeting, store: store)
                .padding(listItemEdgePadding)
            SelectThemeItemView(promiseType: .travel, store: store)
                .padding(listItemEdgePadding)
            SelectThemeItemView(promiseType: .etc, store: store)
                .padding(listItemEdgePadding)
            Spacer()
        }
        .background(Color.white)
    }
}

public struct SelectThemeItemView: View {
    var promiseType: PromiseType
    var store: Store<SelectThemeState, SelectThemeAction>
    let itemCornerRadius: CGFloat = 16
    let checkMarkCircle = "checkmark.circle"
    let checkmarkCircleFill = "checkmark.circle.fill"

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Text(promiseType.withEmoji)
                    .foregroundColor(
                        viewStore.selectedType == promiseType ?
                            PDS.COLOR.purple9.scale :
                            PDS.COLOR.gray5.scale
                    )
                Spacer()
                Image(systemName:
                    viewStore.selectedType == promiseType ?
                        checkmarkCircleFill :
                        checkMarkCircle
                )
                .foregroundColor(
                    viewStore.selectedType == promiseType ?
                        PDS.COLOR.purple9.scale :
                        PDS.COLOR.gray5.scale
                )
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .background(
                viewStore.selectedType == promiseType ?
                    PDS.COLOR.purple9.scale.opacity(0.15) :
                    PDS.COLOR.gray1.scale
            )
            .cornerRadius(itemCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: itemCornerRadius)
                    .stroke(
                        PDS.COLOR.purple9.scale,
                        lineWidth: viewStore.selectedType == promiseType ? 0.7 : 0
                    )
            )
            .onTapGesture {
                viewStore.send(.promiseTypeListItemTapped(promiseType))
            }
        }
    }
}
