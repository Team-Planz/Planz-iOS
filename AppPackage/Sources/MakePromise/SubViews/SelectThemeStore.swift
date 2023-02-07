//
//  MakePromiseSelectThemeStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public enum PromiseType: String, CaseIterable, Equatable {
    case meal = "식사 약속"
    case meeting = "미팅 약속"
    case travel = "여행 약속"
    case etc = "기타 약속"

    var withEmoji: String {
        switch self {
        case .meal: return rawValue + " 🍚"
        case .meeting: return rawValue + " ☕️"
        case .travel: return rawValue + " ✈️"
        case .etc: return rawValue + " ☺️"
        }
    }
}

public struct SelectThemeState: Equatable {
    var selectedType: PromiseType?
}

public enum SelectThemeAction: Equatable {
    case promiseTypeListItemTapped(PromiseType)
}

public struct SelectThemeEnvironment {}

public let makePromiseSelectThemeReducer = AnyReducer<SelectThemeState, SelectThemeAction, SelectThemeEnvironment> { state, action, _ in
    switch action {
    case let .promiseTypeListItemTapped(type):
        state.selectedType = (state.selectedType == type) ? nil : type
        return .none
    }
}
