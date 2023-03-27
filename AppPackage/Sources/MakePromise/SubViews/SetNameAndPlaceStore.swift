//
//  SetNameAndPlaceStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import Foundation

public struct SetNameAndPlaceState: Equatable {
    var maxCharacter = 10
    var promiseName: String = ""
    var promisePlace: String = ""

    var numberOfCharacterInNameText: Int {
        if promiseName.count <= maxCharacter {
            return promiseName.count
        } else {
            return maxCharacter
        }
    }

    var numberOfCharacterInPlaceText: Int {
        if promisePlace.count <= maxCharacter {
            return promisePlace.count
        } else {
            return maxCharacter
        }
    }

    var shouldShowNameTextCountWarning: Bool {
        promiseName.count > maxCharacter
    }

    var shouldShowPlaceTextCountWarning: Bool {
        promisePlace.count > maxCharacter
    }

    var isNextButtonEnable: Bool {
        (numberOfCharacterInNameText > 0 && !shouldShowNameTextCountWarning) && (numberOfCharacterInPlaceText > 0 && !shouldShowPlaceTextCountWarning)
    }

    public init() {}
}

public enum SetNameAndPlaceAction: Equatable {
    case filledPromiseName(String)
    case filledPromisePlace(String)
}

public struct SetNameAndPlaceEnvironment {}

public let makePromiseSetNameAndPlaceReducer = AnyReducer<SetNameAndPlaceState, SetNameAndPlaceAction, SetNameAndPlaceEnvironment> { state, action, _ in
    switch action {
    case let .filledPromiseName(name):
        state.promiseName = name
    case let .filledPromisePlace(place):
        state.promisePlace = place
    }

    return .none
}
