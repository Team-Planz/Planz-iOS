//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import Foundation

public struct MakePromiseEnvironment {
    public init() {}
}

public let makePromiseReducer = AnyReducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment>.combine(
    makePromiseSelectThemeReducer
        .optional()
        .pullback(
            state: \.selectTheme,
            action: /MakePromiseAction.selectTheme,
            environment: { _ in SelectThemeEnvironment() }
        ),
    makePromiseSetNameAndPlaceReducer
        .pullback(
            state: \.setNameAndPlace,
            action: /MakePromiseAction.setNameAndPlace,
            environment: { _ in SetNameAndPlaceEnvironment() }
        ),
    AnyReducer { state, action, _ in
        switch action {
        case .dismiss:
            return .none

        case .nextButtonTapped:
            if state.isNextButtonEnable() {
                state.moveNextStep()
                state.updateBackButtonVisibleState()
            }
            return .none
        case .backButtonTapped:
            state.movePastStep()
            state.updateBackButtonVisibleState()
            return .none
        case let .selectTheme(.promiseTypeListItemTapped(promiseType)):
            return .none
        case let .setNameAndPlace(.filledPromiseName(name)):
            return .none
        case let .setNameAndPlace(.filledPromisePlace(place)):
            return .none
        }
    }
)
