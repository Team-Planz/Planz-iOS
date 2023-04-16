//
//  MakePromiseSelectThemeStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import APIClient
import APIClientLive
import ComposableArchitecture
import Entity
import Foundation
import SwiftUI

public struct SelectTheme: ReducerProtocol {
    public struct State: Equatable {
        var selectThemeItems: IdentifiedArrayOf<SelectThemeItem.State>

        public init(
            selectThemeItems: IdentifiedArrayOf<SelectThemeItem.State> = []
        ) {
            self.selectThemeItems = selectThemeItems
        }
    }

    public enum Action: Equatable {
        case task
        case categoriesResponse(TaskResult<[Entity.Category]>)
        case selectThemeItem(id: Int, action: SelectThemeItem.Action)
    }

    @Dependency(\.apiClient) var apiClient

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .task {
                    await .categoriesResponse(
                        TaskResult {
                            try await apiClient.request(
                                route: .promising(.fetchCategories),
                                as: [Entity.Category].self
                            )
                        }
                    )
                }
            case let .categoriesResponse(.success(categories)):
                state.selectThemeItems = .init(
                    uniqueElements: categories.map {
                        SelectThemeItem.State(
                            id: $0.id,
                            title: $0.keyword
                        )
                    }
                )
                return .none
            case .categoriesResponse(.failure):
                return .none
            case let .selectThemeItem(id: id, action: .tapped):
                state.selectThemeItems.map(\.id).forEach {
                    state.selectThemeItems[id: $0]?.isSelected = ($0 == id)
                }
                return .none
            }
        }
        .forEach(\.selectThemeItems, action: /Action.selectThemeItem(id:action:)) {
            SelectThemeItem()
        }
    }
}
