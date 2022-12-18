//
//  SetNameAndPlaceStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation
import ComposableArchitecture

public struct SetNameAndPlaceState: Equatable {
    var promiseName: String?
    var promisePlace: String?
}

public enum SetNameAndPlaceAction: Equatable {
    case filledPromiseName(String)
    case filledPromisePlace(String)
}

public struct SetNameAndPlaceEnvironment {
    
}

public let  makePromiseSetNameAndPlaceReducer = Reducer<SetNameAndPlaceState, SetNameAndPlaceAction, SetNameAndPlaceEnvironment> { state, action, environment in
    switch action {
    case let .filledPromiseName(name):
        state.promiseName = name
    case let .filledPromisePlace(place):
        state.promisePlace = place
    }
    
    return .none
}
