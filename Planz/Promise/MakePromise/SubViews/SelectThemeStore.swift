//
//  MakePromiseSelectThemeStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public enum PromiseType: String, CaseIterable, Equatable{
    case meal = "식사 약속"
    case meeting = "미팅 약속"
    case travel = "여행 약속"
    case etc = "기타 약속"
    
    var withEmoji : String {
        switch self {
        case .meal: return self.rawValue + " 🍚"
        case .meeting: return self.rawValue + " ☕️"
        case .travel: return self.rawValue + " ✈️"
        case .etc: return self.rawValue + " ☺️"
        }
    }
}

public struct SelectThemeState: Equatable {
    var selectedType: PromiseType? = nil
}

public enum SelectThemeAction: Equatable {
    case promiseTypeListItemTapped(PromiseType)
}

public struct SelectThemeEnvironment {
    
}

public let makePromiseSelectThemeReducer = Reducer<SelectThemeState, SelectThemeAction, SelectThemeEnvironment> { state, action, environment in
    switch action {
    case let .promiseTypeListItemTapped(type):
        state.selectedType = (state.selectedType == type) ? nil : type
        print("@@@ selected type is \(state.selectedType)")
        return .none
    }
}
