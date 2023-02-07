//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import Foundation

public enum MakePromiseStep: Int, Comparable {
    case error = 0
    case selectTheme = 1
    case fillNAndPlace

    public static func < (lhs: MakePromiseStep, rhs: MakePromiseStep) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct MakePromiseState: Equatable {
    var shouldShowBackButton = false
    var currentStep: MakePromiseStep = .selectTheme
    var selectThemeState: SelectThemeState = .init()
    var setNameAndPlaceState: SetNameAndPlaceState = .init()

    func isPossibleToNextContents() -> Bool {
        switch currentStep {
        case .selectTheme:
            return selectThemeState.selectedType != nil
        case .error:
            return false
        case .fillNAndPlace:
            return true
        }
    }
}

public enum MakePromiseAction: Equatable {
    case nextButtonTapped
    case backButtonTapped

    case selectTheme(SelectThemeAction)
    case setNameAndPlace(SetNameAndPlaceAction)
}

public struct MakePromiseEnvironment {}

typealias Step = MakePromiseStep

public let makePromiseReducer = Reducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment>.combine(
    makePromiseSelectThemeReducer
        .pullback(
            state: \.selectThemeState,
            action: /MakePromiseAction.selectTheme,
            environment: { _ in SelectThemeEnvironment() }
        ),
    makePromiseSetNameAndPlaceReducer
        .pullback(
            state: \.setNameAndPlaceState,
            action: /MakePromiseAction.setNameAndPlace,
            environment: { _ in SetNameAndPlaceEnvironment() }
        ),
    Reducer { state, action, _ in
        switch action {
        case .nextButtonTapped:
            if state.isPossibleToNextContents() {
                state.currentStep = Step(rawValue: state.currentStep.rawValue + 1) ?? .error
                state.shouldShowBackButton = state.currentStep > Step.selectTheme
            }
            return .none

        case .backButtonTapped:
            var step = state.currentStep
            var initialStep = Step.selectTheme
            state.currentStep = step > initialStep ? Step(rawValue: step.rawValue - 1) ?? initialStep : initialStep
            state.shouldShowBackButton = state.currentStep > initialStep
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
