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
    var promiseName: String?
    var promisePlace: String?

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
